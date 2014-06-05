require 'bigdecimal'
require 'stringio'
require "excon"

module Ganeti
  attr_accessor   :pool_page_size
  DEFAULT_POOL_PAGE_SIZE = 2000

  if size=ENV['ONE_POOL_PAGE_SIZE']
    if size.strip.match(/^\d+$/) && size.to_i >= 2
      @pool_page_size = size.to_i
    else
      @pool_page_size = nil
    end
  else
    @pool_page_size = DEFAULT_POOL_PAGE_SIZE
  end

  class Client
    attr_reader   :ganeti_endpoint
    
    def initialize(secret=nil, endpoint=nil, options={})
      @options = {}
      ganeti_endpoint = ENV['GANETI_ENDPOINT']
      @keystone_endpoint = ENV['KEYSTONE_ENDPOINT_WITH_PORT']
      endpoint ||= ganeti_endpoint
      @token = options["token"]
      Excon.defaults[:ssl_ca_file] = File.expand_path(File.join(File.dirname(__FILE__), "../..", "certs", "rapi_pub.pem"))
      if !File.exist?(File.expand_path(File.join(File.dirname(__FILE__), "../..", "certs", "rapi_pub.pem")))
        puts "Certificate file does not exist. SSL_VERIFY_PEER set as false"
        Excon.defaults[:ssl_verify_peer] = false
      else
        Excon.defaults[:ssl_verify_peer] = false
      end

      username = ENV['GANETI_USER']
      password = ENV['GANETI_PASSWORD']
      @con = Excon.new(endpoint, :user=>username, :password=>password)
      @con
    end

    def get(path)
      @options[:path] = path
      @options[:method] = 'GET'
      res = @con.request(@options)
      res
    end

    def call(path, method, options=nil)
      begin
        @options[:path] = path
        @options[:headers]={ "Content-Type" => "application/json" }
        @options[:body]=options.to_json
        @options[:method]=method
        res = @con.request(@options)
        puts res.inspect
        res
      rescue Exception => e
        Error.new(e.message)
      end
    end

    def get_token(path, method)
      options={}
      username = ENV['GANETI_USER']
      password = ENV['GANETI_PASSWORD']
      tenantname = ENV['KEYSTONE_TENANT_NAME']
      params = {"auth"=>{"tenantName"=> tenantname, "passwordCredentials"=>{"username"=> username, "password"=> password}}}
      con = Excon.new("#{@keystone_endpoint}/#{path}")
      options[:method]=method
      options[:headers]={ "Content-Type" => "application/json"}
      options[:body]=params.to_json
      res = con.request(options)
      con.reset
      res
    end

    def keystone(path, method, contents={})
      options={}
      con = Excon.new("#{@keystone_endpoint}/#{path}")
      options[:method]=method
      token = get_token('tokens', 'POST')
      if token.data[:status].to_i != 200
        param = { "result" => "token_error", "response" => token }
      return param
      else
        user = JSON.parse(token.data[:body])
        options[:headers]={"Content-Type" => "application/json", "X-Auth-Token" => "#{user['access']['token']['id']}" }
        options[:body]=contents.to_json
        res = con.request(options)
        con.reset
        param = { "result" => "success", "response" => res }
      return param
      end
    end

    def get_version()
      call("system.version")
    end
  end
end

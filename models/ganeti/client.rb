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

    ganeti_endpoint = "https://192.168.2.3:5080"

    
    def initialize(secret=nil, endpoint=nil, options={})
      @options = {}
      endpoint ||= ganeti_endpoint
      @token = options["token"]
      puts "++++++++++++token++++++++++++++"
      puts @token
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
      puts "+++++++++++connection++++++++++++++++"
      puts @con.inspect
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
      res
      rescue Exception => e
        Error.new(e.message)
      end
    end
  

    def get_version()
      call("system.version")
    end
  end
end

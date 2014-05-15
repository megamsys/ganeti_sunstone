# -------------------------------------------------------------------------- #
# Copyright 2002-2014, OpenNebula Project (OpenNebula.org), C12G Labs        #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

module Ganeti
  class User
    #######################################################################
    # Constants and Class Methods
    #######################################################################

    USER_METHODS = {
      :info     => "user.info",
      :allocate => "user.allocate",
      :delete   => "user.delete",
      :passwd   => "user.passwd",
      :chgrp    => "user.chgrp",
      :addgroup => "user.addgroup",
      :delgroup => "user.delgroup",
      :update   => "user.update",
      :chauth   => "user.chauth",
      :quota    => "user.quota"
    }

    SELF      = -1

    # Driver name for default core authentication
    CORE_AUTH = "core"

    # Driver name for default core authentication
    CIPHER_AUTH = "server_cipher"

    # Driver name for ssh authentication
    SSH_AUTH  = "ssh"

    # Driver name for x509 authentication
    X509_AUTH = "x509"

    # Driver name for x509 proxy authentication
    X509_PROXY_AUTH = "x509_proxy"

    # Class constructor
    def initialize(client)
      @path = "/2/info"
      @endpoint = ENV['KEYSTONE_ENDPOINT']
      @client = client
    end

    #######################################################################
    # XML-RPC Methods for the User Object
    #######################################################################

    # Retrieves the information of the given User.
    def info(params)
      # super(USER_METHODS[:info], 'USER')
      #require 'sqlite3'
      #db = SQLite3::Database.new( "ganeti.db" )
      #rows = db.execute( "select * from users where user_name = '" + username + "'" )
      #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
      @info = @client.keystone("users/#{params}", 'GET')
      @info["response"]
    end

    def tenant_info(params)
      @options={}
      options={}
      if params["type"] == "admin"
        res = {
          "ID" => params["user_id"],
          "NAME" => params["username"],
          "GID" => params["tenant"]["id"],
          "GNAME" => params["tenant"]["name"]
        }
      return res
      else
        con = Excon.new("#{@endpoint}/tenants")
        @options[:method]='GET'
        @options[:headers]={ "Content-Type" => "application/json", "X-Auth-Token" => params["token"]}
        res = con.request(@options)
        if res.data[:status].to_i != 200
          result = {
            "ID" => "",
            "NAME" => "",
            "GID" => "",
            "GNAME" => ""
          }
        return result
        else
          json = JSON.parse(res.data[:body])
          result = {
            "ID" => params["user_id"],
            "NAME" => params["username"],
            "GID" => json["tenants"]["id"],
            "GNAME" => json["tenants"]["name"]
          }
        return result
        end
      end
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.keystone("users", 'GET')
      @cc["response"]
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      if @cc["result"] != 'success'
        return empty_json()
      else
        return build_json(@cc["response"])
      end
    end

    def build_json(params)
      user = JSON.parse(params.data[:body])
      i = 0
      js = user["users"].map { |c|
        i = i+1
        builder(i, c)
      }
      j=0
      quota = user["users"].map { |c|
        j = j+1
        quota_builder(j, c)
      }
      json = {
        "USER_POOL"=>{
          "USER"=> js,
          "QUOTAS"=>quota,
          "DEFAULT_USER_QUOTAS"=>{
            "DATASTORE_QUOTA"=>{},
            "NETWORK_QUOTA"=>{},
            "VM_QUOTA"=>{},
            "IMAGE_QUOTA"=>{}
          }}
      }
      json.to_json
    end

    def builder(id, param)
      json = {
        "ID"=>param["id"],
        "GID"=>"0",
        "GROUPS"=>{
          "ID"=>"0"
        },
        "GNAME"=>"oneadmin",
        "NAME"=>param["username"],
        "PASSWORD"=>"f1e91974588eb5a6f87711a1b44ee6d8f3c17522",
        "AUTH_DRIVER"=>"core",
        "ENABLED"=>"1",
        "TEMPLATE"=>{
          "TOKEN_PASSWORD"=>"7e53060a659d012590de42f7da5e876aa2ce494e"
        }
      }
      json
    end

    def quota_builder(id, param)
      json = {
        "ID"=>id,
        "DATASTORE_QUOTA"=>{},
        "NETWORK_QUOTA"=>{},
        "VM_QUOTA"=>{},
        "IMAGE_QUOTA"=>{}}
      json
    end

    def empty_json
      json = {"USER_POOL"=>
        {"USER"=>[{
              "ID"=>"",
              "GID"=>"",
              "GROUPS"=>{
                "ID"=>""
              },
              "GNAME"=>"",
              "NAME"=>"",
              "PASSWORD"=>"",
              "AUTH_DRIVER"=>"",
              "ENABLED"=>"",
              "TEMPLATE"=>{
                "TOKEN_PASSWORD"=>""
              }
            }
          ],
          "QUOTAS"=>[{
              "ID"=>"0",
              "DATASTORE_QUOTA"=>{},
              "NETWORK_QUOTA"=>{},
              "VM_QUOTA"=>{},
              "IMAGE_QUOTA"=>{}}],
          "DEFAULT_USER_QUOTAS"=>{
            "DATASTORE_QUOTA"=>{},
            "NETWORK_QUOTA"=>{},
            "VM_QUOTA"=>{},
            "IMAGE_QUOTA"=>{}
          }}}
      json.to_json
    end

    def info_json
      if @info["result"] != 'success'
        return empty_json()
      else
        return build_info_json(@info["response"])
      end
    end

    def build_info_json(params)
      user = JSON.parse(params.data[:body])
      res = {
        "USER"=> {
          "ID"=> user["user"]["id"],
          "GID"=> "1",
          "GROUPS"=> {
            "ID"=> "1"
          },
          "GNAME"=> "users",
          "NAME"=> user["user"]["username"],
          "PASSWORD"=> "1f8ac10f23c5b5bc1167bda84b833e5c057a77d2",
          "AUTH_DRIVER"=> "core",
          "ENABLED"=> "1",
          "TEMPLATE"=> {
            "TOKEN_PASSWORD"=> "e5d6a0dba76545a03420655b9ebeeeb7b768e384"
          },
          "DATASTORE_QUOTA"=> {
          },
          "NETWORK_QUOTA"=> {
          },
          "VM_QUOTA"=> {
          },
          "IMAGE_QUOTA"=> {
          },
          "DEFAULT_USER_QUOTAS"=> {
            "DATASTORE_QUOTA"=> {
            },
            "NETWORK_QUOTA"=> {
            },
            "VM_QUOTA"=> {
            },
            "IMAGE_QUOTA"=> {
            }
          }
        }
      }
      res.to_json
    end

    alias_method :info!, :info

    #######################################################################
    # Helpers to get User information
    #######################################################################

    # Returns the group identifier
    # [return] _Integer_ the element's group ID
    def gid
      self['GID'].to_i
    end

    # Returns a list with all the group IDs for the user including primary
    # [return] _Array_ with the group ID's (as integers)
    def groups
      all_groups = self.retrieve_elements("GROUPS/ID")
      all_groups.collect! {|x| x.to_i}
    end
  end
end

#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

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

#This is modified by Megam Systems.

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
      @endpoint = ENV['KEYSTONE_ENDPOINT_WITHOUT_PORT']
      @client = client
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
        con = Excon.new("#{@endpoint}:5000/v2.0/tenants")
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
            #"GID" => json["tenants"]["id"],
            #"GNAME" => json["tenants"]["name"]
            "GID" => "",
            "GNAME" => ""
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
        "PASSWORD"=>"",
        "AUTH_DRIVER"=>"core",
        "ENABLED"=>"1",
        "TEMPLATE"=>{}
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
              "TEMPLATE"=>{}
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

    # Retrieves the information of the given User.
    def info(params)
      user_id = (params.split("-"))[0]
      @info = @client.keystone("users/#{user_id}", 'GET')
      @info["response"]
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
          "GID"=> user["user"]["tenantId"],
          "GROUPS"=> {
            "ID"=> "1"
          },
          "GNAME"=> "users",
          "NAME"=> user["user"]["username"],
          "PASSWORD"=> "",
          "AUTH_DRIVER"=> "core",
          "ENABLED"=> user["user"]["enabled"],
          "EMAIL" => user["user"]["email"],
          "TEMPLATE"=> {},
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

    def create(options)
      user = JSON.parse(options)
      contents = {
        "user" => {
          "name" => user["user"]["name"],
          "enabled"=> true,
          "OS-KSADM:password"=> user["user"]["password"]
        }
      }
      create = @client.keystone("users", 'POST', contents)
      create["response"]
    end

    def action(params, action_json)
      user_id = (params.split("-"))[0]
      json = JSON.parse(action_json)  
      case "#{json['action']['perform']}"
      when "addgroup"
        return addgroup(user_id, json)
      when "passwd"  
        return change_password(user_id, json)
      when "chgrp"
        return addgroup(user_id, json)  
    #  when "delgroup"
     #   return delgroup(user_id, json)  
      end
    end

    def addgroup(id, json)
      gid = json['action']['params']['group_id'].split(":")
      contents = {
        "user" => {
          "tenantId" => gid[0]
        }
      }
      create = @client.keystone("users/#{id}", 'PUT', contents)
      create["response"]
    end
=begin    
    def delgroup(id, json)
      gid = json['action']['params']['group_id'].split(":")
      contents = {
        "user" => {
          "tenantId" => "null"
        }
      }
      create = @client.keystone("users/#{id}", 'PUT', contents)
      create["response"]
    end
=end
    def delete(id)
      del = @client.keystone("users/#{id}", 'DELETE')
      del["response"]
    end
    
    def change_password(id, json)
      contents = {
        "user" => {
          "password"=> json['action']['params']['password']
        }
      }
      create = @client.keystone("users/#{id}", 'PUT', contents)
      create["response"]
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

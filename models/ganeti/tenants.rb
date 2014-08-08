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

require 'ganeti/pool_element'

module Ganeti
  class Tenants < PoolElement
    def initialize(client)
      @path = "/2/groups"
      @client = client
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.keystone("tenants", 'GET')
      @cc["response"]
    end

    def to_json
      if @cc["result"] != 'success'
        return empty_json()
      else
        return build_json(@cc["response"])
      end
    end

    def info(param)
      @info = @client.keystone("tenants/#{param}", 'GET')
      @info["response"]
    end

    def info_json
      if @info["result"] != 'success'
        return empty_json()
      else
        if @info["response"].data[:status].to_i != 200
          return empty_json()
        else
          return build_info_json(@info["response"])
        end
      end
    end

    def build_info_json(params)
      tenant = JSON.parse(params.data[:body])
      no_of_users = get_users(tenant["tenant"]["id"])
      res = {
        "GROUP"=> {
          "ID"=> tenant["tenant"]["id"],
          "NAME"=> tenant["tenant"]["name"],
          "NOOFUSERS" => no_of_users,
          "ENABLED" => tenant["tenant"]["enabled"],
          "DESCRIPTION" => tenant["tenant"]["description"],
          "TEMPLATE"=> {},
          "USERS"=> {
            "ID"=> "0"
          },
          "RESOURCE_PROVIDER"=> {
            "ZONE_ID"=> "0",
            "CLUSTER_ID"=> "10"
          },
          "DATASTORE_QUOTA"=> {},
          "NETWORK_QUOTA"=> {},
          "VM_QUOTA"=> {},
          "IMAGE_QUOTA"=> {},
          "DEFAULT_GROUP_QUOTAS"=> {
            "DATASTORE_QUOTA"=> {},
            "NETWORK_QUOTA"=> {},
            "VM_QUOTA"=> {},
            "IMAGE_QUOTA"=> {}
          }
        }
      }
      res.to_json
    end

    def get_users(id)
      @info = @client.keystone("tenants/#{id}/users", 'GET')
      res = @info["response"]
      if res[:status].to_i != 200
      return 0
      else
        users = JSON.parse(res.data[:body])
        return users["users"].count
      end
    end

    def empty_json
      json = {"GROUP_POOL"=>
        {
          "GROUP"=> {
            "ID"=> 0,
            "NAME"=> "SERVER ERROR",
            "NOOFUSERS" => 0,
            "ENABLED" => "SERVER ERROR",
            "DESCRIPTION" => "SERVER ERROR",
            "CLUSTER" => "SERVER ERROR",
            "TEMPLATE"=> {
              "GROUP_ADMINS"=> "customer1-admin",
              "GROUP_ADMIN_VIEWS"=> "vdcadmin",
              "SUNSTONE_VIEWS"=> "user"
            },
            "USERS"=> {
              "ID"=> "2"
            },
            "RESOURCE_PROVIDER"=> {
              "ZONE_ID"=> "0",
              "CLUSTER_ID"=> "10"
            },
            "DATASTORE_QUOTA"=> {},
            "NETWORK_QUOTA"=> {},
            "VM_QUOTA"=> {},
            "IMAGE_QUOTA"=> {},
            "DEFAULT_GROUP_QUOTAS"=> {
              "DATASTORE_QUOTA"=> {},
              "NETWORK_QUOTA"=> {},
              "VM_QUOTA"=> {},
              "IMAGE_QUOTA"=> {}
            }
          }
        }
      }
      json.to_json
    end

    def build_json(params)
      tenants = JSON.parse(params.data[:body])
      i = 0
      js = tenants["tenants"].map { |c|
        i = i+1
        builder(i, c)
      }
      j=0
      quota_json = tenants["tenants"].map { |c|
        j = j+1
        getQuotaJson(j)
      }
      json = {
        "GROUP_POOL" => {
          "GROUP" =>  js,
          "QUOTAS"=> quota_json,
          "DEFAULT_GROUP_QUOTAS"=>{
            "DATASTORE_QUOTA"=>{},
            "NETWORK_QUOTA"=>{},
            "VM_QUOTA"=>{},
            "IMAGE_QUOTA"=>{}
          }
        }
      }
      json.to_json
    end

    def builder(id, param)
      cluster_name = get_cluster()
      b_json = {
        "ID" => param["id"],
        "NAME" => param["name"],
        "NOOFUSERS" => 2,
        "CLUSTER" => cluster_name,
        "TEMPLATE" => {},
        "USERS" => {
          "ID" => ["0","1"]
        }
      }
      b_json
    end

    def getQuotaJson(id)
      q_json = {
        "ID"=>id,
        "DATASTORE_QUOTA"=>{},
        "NETWORK_QUOTA"=>{},
        "VM_QUOTA"=>{},
        "IMAGE_QUOTA"=>{}
      }
      q_json
    end

    def get_cluster
      res = Ganeti::Zones.new(@client)
      zone = res.call
      cluster_name = ""
      if zone.data[:status].to_i == 200
        cluster = JSON.parse(res.to_json)
        cluster_name = cluster["ZONE_POOL"]["ZONE"]["NAME"]
      else
        cluster_name = ""
      end
      cluster_name
    end

    def create(options)
      tenant = JSON.parse(options)
      contents = {
        "tenant" => {
          "name" => tenant["group"]["name"],
          "description" => "",
          "enabled" => true
        }
      }
      create = @client.keystone("tenants", 'POST', contents)
      create["response"]
    end

    def delete(id)
      del = @client.keystone("tenants/#{id}", 'DELETE')
      del["response"]
    end

  end
end

=begin
json = {
"GROUP_POOL" => {
"GROUP" => [{
"ID" => "0",
"NAME" => "oneadmin",
"TEMPLATE" => {},
"USERS" => {
"ID" => ["0","1"]
}
},
{
"ID" => "1",
"NAME"=>"users",
"TEMPLATE"=>{},
"USERS"=>{},
"RESOURCE_PROVIDER"=>{
"ZONE_ID"=>"0",
"CLUSTER_ID"=>"10"
}
},
{
"ID"=>"100",
"NAME"=>"customer1",
"TEMPLATE"=>{
"GROUP_ADMINS"=>"customer1-admin",
"GROUP_ADMIN_VIEWS"=>"vdcadmin",
"SUNSTONE_VIEWS"=>"user"
},
"USERS"=>{
"ID"=>"2"
},
"RESOURCE_PROVIDER"=>{
"ZONE_ID"=>"0",
"CLUSTER_ID"=>"10"
}}],
"QUOTAS"=>[{
"ID"=>"0",
"DATASTORE_QUOTA"=>{},
"NETWORK_QUOTA"=>{},
"VM_QUOTA"=>{},
"IMAGE_QUOTA"=>{}
},{
"ID"=>"1",
"DATASTORE_QUOTA"=>{},
"NETWORK_QUOTA"=>{},
"VM_QUOTA"=>{},
"IMAGE_QUOTA"=>{}
},{
"ID"=>"100",
"DATASTORE_QUOTA"=>{},
"NETWORK_QUOTA"=>{},
"VM_QUOTA"=>{},
"IMAGE_QUOTA"=>{}
}],
"DEFAULT_GROUP_QUOTAS"=>{
"DATASTORE_QUOTA"=>{},
"NETWORK_QUOTA"=>{},
"VM_QUOTA"=>{},
"IMAGE_QUOTA"=>{}
}
}
}
=end


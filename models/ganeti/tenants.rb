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
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      if @cc["result"] != 'success'
        return empty_json()
      else
        return build_json(@cc["response"])
      end
    end

    def info(param)
      @param = param
      @cli = @client.call(@path+"/"+@param, 'GET')
      @cli
    end

    def info_json
      ins_data = @client.call(@path+"/"+@param, 'GET')
      inst_data = JSON.parse(ins_data.data[:body])
      no_of_hosts = inst_data["node_list"].count
      cluster_name = get_cluster()
      json = {
        "TENANT"=> {
          "ID"=> inst_data["serial_no"],
          "NAME"=> inst_data["name"],
          "NOOFHOSTS" => no_of_hosts,
          "CLUSTER" => cluster_name,
          "TEMPLATE"=> {
            "TENANT_ADMINS"=> "customer1-admin",
            "TENANT_ADMIN_VIEWS"=> "vdcadmin",
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
          "DEFAULT_TENANT_QUOTAS"=> {
            "DATASTORE_QUOTA"=> {},
            "NETWORK_QUOTA"=> {},
            "VM_QUOTA"=> {},
            "IMAGE_QUOTA"=> {}
          }
        }
      }
      json.to_json
    end

    def build_json(params)
      tenants = JSON.parse(params.data[:body])
      puts "-------------response--------"
      puts tenants
      i = 0
      js = tenants["tenants"].map { |c|
        i = i+1
        builder(i, c)
      }
      puts "---------------js-----------"
      puts js
      j=0
      quota_json = tenants["tenants"].map { |c|
        j = j+1
        getQuotaJson(j)
      }
      puts "-----------quote----------------"
      puts quota_json
      json = {
        "TENANT_POOL" => {
          "TENANT" =>  js,
          "QUOTAS"=> quota_json,
          "DEFAULT_TENANT_QUOTAS"=>{
            "DATASTORE_QUOTA"=>{},
            "NETWORK_QUOTA"=>{},
            "VM_QUOTA"=>{},
            "IMAGE_QUOTA"=>{}
          }
        }
      }
      puts "---------------json--------------------"
      puts json
      json.to_json
    end

    def builder(id, param)
      cluster_name = get_cluster()
      puts "----------cluster-----------------"
      puts cluster_name
      b_json = {
        "ID" => id,
        "NAME" => param["name"],
        "NOOFHOSTS" => 2,
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



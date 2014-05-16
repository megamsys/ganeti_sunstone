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
  class HostGroups < PoolElement
    def initialize(client)
      @path = "/2/groups"
      @client = client
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
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
        "HGROUP"=> {
          "ID"=> inst_data["serial_no"],
          "NAME"=> inst_data["name"],
          "NOOFHOSTS" => no_of_hosts,
          "CLUSTER" => cluster_name,
          "TEMPLATE"=> {
            "HGROUP_ADMINS"=> "customer1-admin",
            "HGROUP_ADMIN_VIEWS"=> "vdcadmin",
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
          "DEFAULT_HGROUP_QUOTAS"=> {
            "DATASTORE_QUOTA"=> {},
            "NETWORK_QUOTA"=> {},
            "VM_QUOTA"=> {},
            "IMAGE_QUOTA"=> {}
          }
        }
      }
      json.to_json
    end

    def to_json
      c1 = JSON.parse(@cc.data[:body])
      i = 0
      js = c1.map { |c|
        i = i+1
        build_json(i, c["name"])
      }
      quota_json = c1.map { |c|
        i = i+1
        getQuotaJson(i)
      }
      json = {
        "HGROUP_POOL" => {
          "HGROUP" =>  js,
          "QUOTAS"=> quota_json,
          "DEFAULT_HGROUP_QUOTAS"=>{
            "DATASTORE_QUOTA"=>{},
            "NETWORK_QUOTA"=>{},
            "VM_QUOTA"=>{},
            "IMAGE_QUOTA"=>{}
          }
        }
      }
      json.to_json
    end

    def build_json(id, name)
      cli = @client.call(@path+"/"+name, 'GET')
      inst_data = JSON.parse(cli.data[:body])
      no_of_nodes = inst_data["node_list"].count

      cluster_name = get_cluster()

      b_json = {
        "ID" => inst_data["serial_no"],
        "NAME" => name,
        "NOOFHOSTS" => no_of_nodes,
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



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
require 'json'

module Ganeti
  class VirtualNetworks
    def initialize(client)
      @path = "/2/networks"
      @client = client
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      json = {}
      if @cc.data[:body].length > 0
        vnet = JSON.parse(@cc.data[:body])
        json = {
          "VNET_POOL" => build_json(0, "name")
        }
      else
        json = {
          "VNET_POOL" => {}
        }
      end
      json.to_json
    end

    def info(param=nil)
      @cli = @client.call(@path, 'GET')
      @cli
    end

    def info_json
      zone = JSON.parse(@cli.data[:body])
      json = build_json(0, "name")
      json.to_json
    end

    def build_json(id, name)
      #ins_data = @client.call(@path+"/#{name}", 'GET')
      #inst_data = JSON.parse(ins_data.data[:body])

      b_json = {
        "VNET"=> {
          "ID"=> "0",
          "UID"=> "0",
          "GID"=> "0",
          "UNAME"=> "oneadmin",
          "GNAME"=> "oneadmin",
          "NAME"=> "sample",
          "PERMISSIONS"=> {
            "OWNER_U"=> "1",
            "OWNER_M"=> "1",
            "OWNER_A"=> "0",
            "GROUP_U"=> "0",
            "GROUP_M"=> "0",
            "GROUP_A"=> "0",
            "OTHER_U"=> "0",
            "OTHER_M"=> "0",
            "OTHER_A"=> "0"
          },
          "CLUSTER_ID"=> "-1",
          "CLUSTER"=> {
          },
          "TYPE"=> "1",
          "BRIDGE"=> "testing",
          "VLAN"=> "0",
          "PHYDEV"=> {
          },
          "VLAN_ID"=> {
          },
          "GLOBAL_PREFIX"=> {
          },
          "SITE_PREFIX"=> {
          },
          "TOTAL_LEASES"=> "0",
          "TEMPLATE"=> {
            "BRIDGE"=> "testing",
            "DESCRIPTION"=> "testing",
            "DNS"=> "dns",
            "GATEWAY"=> "dfgdg",
            "NETWORK_ADDRESS"=> "192.122.2.3",
            "NETWORK_MASK"=> "mask",
            "PHYDEV"=> "",
            "VLAN"=> "NO",
            "VLAN_ID"=> ""
          },
          "LEASES"=> {
          }
        }
      }

      b_json
    end

  end
end 
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
      @VNET_METHODS = {
            "addgrp"     => {"METHOD" => "PUT", "ACTION" => "connect"},
            "rmgrp"      => {"METHOD" => "PUT", "ACTION" => "disconnect"}
        }
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def create(json)
     @options = {}
      post_data = JSON.parse(json)
      puts post_data

      net_start = post_data["vnet"]["ip_start"]
      net_end = post_data["vnet"]["ip_end"].split(".")
      net = net_end.last
      network = "#{net_start}/#{net}"
      ips = post_data["vnet"]["ips"].split(",")
      options = {
        "add_reserved_ips" => ips,
        "gateway" => post_data["vnet"]["gateway"],
        "mac_prefix" => post_data["vnet"]["mac_prefix"],
        "conflicts_check" => false,
        "network" => network,
        "network_name" => post_data["vnet"]["name"]
      }
      post = @client.call(@path, 'POST', options)
      puts post.inspect
      post
    end

    def to_json
      json = {}
      vnet = JSON.parse(@cc.data[:body])
      if vnet.empty?
        json = {
          "VNET_POOL" => {}
        }
      else
        vnet.map {|c| puts c["name"]}
        i = 0
        js = vnet.map { |c|
          i = i+1
          builder(i, c["name"])
        }
        json = {
          "VNET_POOL" => {
            "VNET"=> js
          }
        }
      end
      json.to_json
    end

    def builder(id, name)
      b_json = {
        "ID"=> id,
        "UID"=> "0",
        "GID"=> "0",
        "UNAME"=> "oneadmin",
        "GNAME"=> "oneadmin",
        "NAME"=> name,
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
        "PHYDEV"=> {},
        "VLAN_ID"=> {},
        "GLOBAL_PREFIX"=> {},
        "SITE_PREFIX"=> {},
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
      b_json
    end

    def info(param=nil)
      @param = param
      @cli = @client.call(@path, 'GET')
      @cli
    end

    def info_json
      zone = JSON.parse(@cli.data[:body])
      json = build_json(@param)
      json.to_json
    end

    def build_json(param)
      name = param.split(",")[0]
      ins_data = @client.call(@path+"/#{name}", 'GET')
      inst_data = JSON.parse(ins_data.data[:body])
      group_list = inst_data["group_list"].map { |net|
        net[0] + " (" + net[1] + " on " + net[2] + ")"
      }
      b_json = {
        "VNET"=> {
          "ID"=> inst_data["serial_no"],
          "UID"=> "0",
          "GID"=> "0",
          "UNAME"=> "oneadmin",
          "GNAME"=> "oneadmin",
          "NAME"=> inst_data["name"],
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
          "UUID"=> inst_data["uuid"],
          "RESERVED_COUNT"=> inst_data["reserved_count"],
          "EXTERNAL_RESERVATIONS"=> inst_data["external_reservations"],
          "MAC_PREFIX"=> inst_data["mac_prefix"],
          "GROUP_LIST"=> group_list,
          "CTIME"=> inst_data["ctime"],
          "MTIME"=> inst_data["mtime"],
          "GATEWAY6"=> inst_data["gateway6"],
          "NETWORK6"=> inst_data["network6"],
          "GATEWAY"=> inst_data["gateway"],
          "NETWORK"=> inst_data["network"],
          "VLAN"=> "0",
          "PHYDEV"=> {},
          "VLAN_ID"=> {},
          "GLOBAL_PREFIX"=> {},
          "SITE_PREFIX"=> {},
          "TOTAL_LEASES"=> "0",
          "TEMPLATE"=> {},
          "LEASES"=> {
          }
        }
      }

      b_json
    end

    def delete(id)
      del = @client.call(@path+"/"+id, 'DELETE')
      del
    end

    def purge(id)
    end

    def action(id, action_json)
      json = JSON.parse(action_json)
      puts json['action']['params']["group_id"]
      data = @VNET_METHODS[json["action"]["perform"]]
      net_data = json['action']['params']["group_id"].split(":")
      options = get_options(data, net_data)
      res = @client.call(@path+"/"+id+"/"+data["ACTION"], data["METHOD"], options)
      res
    end

    def get_options(data, net_data)
      options={}
      case data["ACTION"]
      when "connect"
        options = {
          "group_name" => net_data[1],
          "network_link" => net_data[3],
          "network_mode" => net_data[2]
        }
      when "disconnect"
        options = {
          "group_name" => net_data[1]
        }
      else
      options = {
      "group_name" => "",
      "network_link" => "",
      "network_mode" => ""
      }
      end
      options
    end

  end
end 
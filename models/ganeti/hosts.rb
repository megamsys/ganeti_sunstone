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
  class Hosts
    def initialize(client)
      @path = "/2/nodes"
      @client = client
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      c1 = JSON.parse(@cc.data[:body])
      c1.map {|c| puts c["id"]}
      i = 0
      js = c1.map { |c|
        i = i+1
        build_json(i, c["id"])
      }
      json = {
        "HOST_POOL" => {
          "HOST" => js
        }
      }
      json.to_json
    end

    def info(param)
      # @param = param.split("-")
      @param = param
      @cli = @client.call(@path+"/"+@param, 'GET')
      @cli
    end

    def info_json
      json = {
        "HOST"=> build_json(@param)
      }
      json.to_json
    end

    def build_json(id=nil, name)
      ins_data = @client.call(@path+"/#{name}", 'GET')
      inst_data = JSON.parse(ins_data.data[:body])
      @noi = 0
      no_of_instances = inst_data["pinst_list"].count
      vms = inst_data["pinst_list"].map { |i| {"id" => i} }
      b_json = {
        "ID" => inst_data["serial_no"],
        "NAME" => name,
        "STATE" => "2",
        "IM_MAD" => "",
        "VM_MAD" => "",
        "VN_MAD" => "",
        "CTIME" => inst_data["ctime"],
        "LAST_MON_TIME" => "",
        "CLUSTER_ID" => "-1",
        "CLUSTER" => {},
        "HOST_SHARE" => {
          "DISK_USAGE" => inst_data["dtotal"]-inst_data["dfree"],
          "MEM_USAGE" => inst_data["mtotal"]-inst_data["mfree"],
          "CPU_USAGE" => "0",
          "MAX_DISK" => inst_data["dtotal"],
          "MAX_MEM" => inst_data["mtotal"],
          "MAX_CPU" => "2200",
          "FREE_DISK" => inst_data["dfree"],
          "FREE_MEM" => inst_data["mfree"],
          "FREE_CPU" => "2200",
          "USED_DISK" => inst_data["dtotal"]-inst_data["dfree"],
          "USED_MEM" => inst_data["mtotal"]-inst_data["mfree"],
          "USED_CPU" => "0",
          "RUNNING_VMS_COUNT" => no_of_instances,
          "RUNNING_VMS" => inst_data["pinst_list"],
          "DATASTORES" => {}},
        "VMS" => vms,
        "TEMPLATE" => {}
      }
      b_json
    end

  end
end 
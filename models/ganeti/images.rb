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
  class Images
    def initialize(client)
      @path = "/2/os"
      @client = client
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      image = JSON.parse(@cc.data[:body])
      json = {
        "IMAGE_POOL" => build_json(0, image)
      }
      json.to_json
    end

    def info(param=nil)
      @param = param.split('-')
      @cli = @client.call(@path, 'GET')
      @cli
    end

    def info_json
      image = JSON.parse(@cli.data[:body])
       json = {
        "IMAGE" => getImageJson(@param[0], @param[1])
      }
      json.to_json
    end

    def getImageJson(id, name)
      js = {
            "ID"=>id,
            "UID"=>"0",
            "GID"=>"0",
            "UNAME"=>"oneadmin",
            "GNAME"=>"default",
            "NAME"=>name,
            "PERMISSIONS"=>{
              "OWNER_U"=>"1",
              "OWNER_M"=>"1",
              "OWNER_A"=>"0",
              "GROUP_U"=>"0",
              "GROUP_M"=>"0",
              "GROUP_A"=>"0",
              "OTHER_U"=>"0",
              "OTHER_M"=>"0",
              "OTHER_A"=>"0"
            },
            "TYPE"=>"0",
            "DISK_TYPE"=>"0",
            "PERSISTENT"=>"0",
            "REGTIME"=>"1399291045",
            "SOURCE"=>"/var/lib/one//datastores/1/f43dec5040ad3185deb5e4d34736b6b4",
            "PATH"=>"/var/tmp",
            "FSTYPE"=>{
            },
            "SIZE"=>"1",
            "STATE"=>"1",
            "RUNNING_VMS"=>"0",
            "CLONING_OPS"=>"0",
            "CLONING_ID"=>"-1",
            "DATASTORE_ID"=>"1",
            "DATASTORE"=>"default",
            "VMS"=>{
            },
            "CLONES"=>{
            },
            "TEMPLATE"=>{}
          }
         js 
    end

    def build_json(id=nil, name)
      #  ins_data = @client.call(@path+"/#{name}", 'GET')
      # inst_data = JSON.parse(ins_data.data[:body])
      i = 0
      img_json = name.map { |c|
          i = i+1 
          getImageJson(i, c)
      }
      b_json = {
        "IMAGE" => img_json
      }
      b_json
    end

  end
end 
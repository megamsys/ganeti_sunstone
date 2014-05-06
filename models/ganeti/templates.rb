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
  class Templates
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
      zone = JSON.parse(@cc.data[:body])
      json = {
        "VMTEMPLATE_POOL"=>{
          "VMTEMPLATE"=>{
            "ID"=>"1",
            "UID"=>"0",
            "GID"=>"0",
            "UNAME"=>"oneadmin",
            "GNAME"=>"oneadmin",
            "NAME"=>"ec2_nk_singapore",
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
            "REGTIME"=>"1397617636",
            "TEMPLATE"=>{
              "CPU"=>"1",
              "EC2"=>{
                "AMI"=>"ami-d85f0c8a",
                "INSTANCETYPE"=>"m1.small",
                "KEYPAIR"=>"megam_ec2",
                "SECURITYGROUPS"=>"megam"
              },
              "MEMORY"=>"1700"
            }
          }
        }
      }
      json.to_json
    end

  end
end 
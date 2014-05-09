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

    def connect
      require 'sqlite3'
      db = SQLite3::Database.new( "ganeti.db" )
      db.execute("PRAGMA foreign_keys = ON;")
      db
    end

    def create(template)
      data = JSON.parse(template)
      image = data['vmtemplate']['DISK'][0]['IMAGE']
      time = Time.new
      rows = connect.execute("insert into templates(uid, name, memory, disk_size, cpu, os, created_at) values(1, '"+data['vmtemplate']['NAME']+"', '"+data['vmtemplate']['MEMORY']+"', '"+data['vmtemplate']['DISK_SIZE']+"', '"+data['vmtemplate']['CPU']+"', '"+image+"', '"+time.inspect+"')")
      puts rows
      data
    end

    def to_json
      #zone = JSON.parse(@cc.data[:body])
      inst_data = connect.execute( "select * from templates where uid = 1" )
      puts inst_data.class
      js = inst_data.map { |c|
         build_json(c)
      }
      json = {
        "VMTEMPLATE_POOL"=>{
          "VMTEMPLATE"=> js }
        }
        json.to_json
     end
     
     def build_json(tem_data)
       js = {  
            "ID"=>tem_data[0],
            "UID"=>tem_data[1],
            "GID"=>"0",
            "UNAME"=>"oneadmin",
            "GNAME"=>"oneadmin",
            "NAME"=>tem_data[2],
            "OS"=>tem_data[6],
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
            "REGTIME"=>tem_data[7],
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
      js
    end

    def info(param=nil)
      @param = param.split('-')
      puts @param
      @cli = @client.call(@path, 'GET')
      @cli
    end

    def info_json
      image = JSON.parse(@cli.data[:body])
      json = {
        "VMTEMPLATE" => getImageJson(@param[0], @param[1])
      }
      json.to_json
    end

    def getImageJson(id, name)
      require 'sqlite3'
      db = SQLite3::Database.new( "ganeti.db" )
      rows = db.execute( "select * from templates where id = '" + id + "'" )
      js = {
        "ID"=>rows[0][0],
        "UID"=>"0",
        "GID"=>"0",
        "UNAME"=>"oneadmin",
        "GNAME"=>"oneadmin",
        "NAME"=>rows[0][2],
        "OS"=>rows[0][6],
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
        "MEMORY"=>rows[0][3],
        "CPU"=>rows[0][5],
        "DISK_SIZE"=>rows[0][4],
        "REGTIME"=>rows[0][7],
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
      js
    end

  end
end 
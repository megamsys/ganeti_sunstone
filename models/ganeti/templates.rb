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
    def initialize(client=nil)
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
      db = SQLite3::Database.new("ganeti.db")
      db.execute("PRAGMA foreign_keys = ON;")
      db
    end

    def create(template)
      data = JSON.parse(template)

      puts template
      hash = JSON[template]
      puts hash
      if hash['vmtemplate'].has_key?("DISK")
        image = hash['vmtemplate']['DISK'][0]['IMAGE']
      else
        image = 'debootstrap+default'
      end

      if hash['vmtemplate'].has_key?("DISK_SIZE")
        disk_size = hash['vmtemplate']['DISK_SIZE']
      else
        disk_size = '512'
      end

      if hash['vmtemplate'].has_key?("SCHED_REQUIREMENTS")
        puts "if disk size"
        host_name = (hash['vmtemplate']['SCHED_REQUIREMENTS'].split("="))[1]
      else
        puts "else disk size"
        host_name = ''
      end

      if hash['vmtemplate'].has_key?("CONTEXT")
        if hash['vmtemplate']['CONTEXT'].has_key?("SSH_PUBLIC_KEY")
          if hash['vmtemplate']['CONTEXT']['SSH_PUBLIC_KEY'] == '$USER[SSH_PUBLIC_KEY]'
            sshkey = ''
          else
            sshkey = hash['vmtemplate']['CONTEXT']['SSH_PUBLIC_KEY']
          end
        else
          sshkey = ''
        end
      else
        sshkey = ''
      end

      if hash['vmtemplate'].has_key?("NETWORK_NAME")
        network = hash['vmtemplate']['NETWORK_NAME']
      else
        network = ''
      end

      time = Time.new
      rows = connect.execute("insert into templates(uid, name, memory, disk_size, cpu, os, host_name, machine, kernel_path, initrd, kernel_args, network_name, sshkey, created_at) values(1, '"+data['vmtemplate']['NAME']+"', '"+data['vmtemplate']['MEMORY']+"', '"+disk_size+"', '"+data['vmtemplate']['CPU']+"', '"+image+"', '"+host_name+"', '"+data['vmtemplate']['OS']['MACHINE']+"', '"+data['vmtemplate']['OS']['KERNEL']+"', '"+data['vmtemplate']['OS']['INITRD']+"', '"+data['vmtemplate']['OS']['KERNEL_CMD']+"', '"+network+"', '"+sshkey+"', '"+time.inspect+"')")
      puts rows
      {:status => 200}
    end

    def to_json
      #zone = JSON.parse(@cc.data[:body])
      json={}
      inst_data = connect.execute( "select * from templates where uid = 1" )
      if inst_data.empty?
        json = {
          "VMTEMPLATE_POOL"=>{}
        }
      else
        js = inst_data.map { |c|
          build_json(c)
        }
        json = {
          "VMTEMPLATE_POOL"=>{
            "VMTEMPLATE"=> js }
        }
      end
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
        "REGTIME"=>tem_data[14],
        "TEMPLATE"=>{
          "CPU"=>tem_data[5],
          "OS"=>{"MACHINE"=>tem_data[8], "KERNEL_CMD"=>tem_data[11], "KERNEL"=>tem_data[9], "INITRD"=>tem_data[10]},
          # "EC2"=>{
          #  "AMI"=>"ami-d85f0c8a",
          # "INSTANCETYPE"=>"m1.small",
          # "KEYPAIR"=>"megam_ec2",
          # "SECURITYGROUPS"=>"megam"
          # },
          "MEMORY"=>tem_data[3]
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

    def getImageJson(id, name=nil)
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
        "HOST_NAME"=>rows[0][7],
        "NETWORK"=>rows[0][12],
        "REGTIME"=>rows[0][14],
        "TEMPLATE"=>{
          "CPU"=>rows[0][5],
          "OS"=>{"MACHINE"=>rows[0][8], "KERNEL_CMD"=>rows[0][11], "KERNEL"=>rows[0][9], "INITRD"=>rows[0][10]},
          #"EC2"=>{
          #  "AMI"=>"ami-d85f0c8a",
          # "INSTANCETYPE"=>"m1.small",
          # "KEYPAIR"=>"megam_ec2",
          # "SECURITYGROUPS"=>"megam"
          # },
          "MEMORY"=>rows[0][3]
        }
      }
      js
    end

    def delete(param)
      id = param.split("-")[0]
      require 'sqlite3'
      db = SQLite3::Database.new( "ganeti.db" )
      rows = db.execute( "DELETE FROM templates WHERE id = '" + id + "'" )
      {:status => 200}
    end

    def purge(id)
    end

    def get_sshkey(param)
      auth_options={}
      admin_username = ENV['GANETI_USER']
      admin_password = ENV['GANETI_PASSWORD']
      if param["username"] == admin_username && param["password"] == admin_password
        port = 35357
        type = "admin"
        options = {"auth"=>{"tenantName"=> "admin", "passwordCredentials"=>{"username"=> param["username"], "password"=> param["password"]}}}
      else
        port = 5000
        type = "user"
        options = {"auth"=>{"passwordCredentials"=>{"username"=> param["username"], "password"=> param["password"]}}}
      end
      con = Excon.new("http://192.168.2.3:#{port}/v2.0/tokens")
      auth_options[:method]='POST'
      auth_options[:headers]={ "Content-Type" => "application/json"}
      auth_options[:body]=options.to_json
      res = con.request(auth_options)
      con.reset
      if res[:status] == 200
        require 'sqlite3'
        db = SQLite3::Database.new( "ganeti.db" )
        inst_data = connect.execute( "select * from vms where vm_name = '" + param["instance_name"] + "'" )
        template_id = inst_data[0][7]
        data = connect.execute( "select * from templates where id = #{template_id} " )
      return data[0][13]
      else
        return ""
      end
    end

  end
end 
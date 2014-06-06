# Copyright [2013-2014] [Megam Systems]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Ganeti
  class Templates
    def initialize(client=nil, options={})
      @path = "/2/os"
      @client = client
      @user_details = options
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
        image = hash['vmtemplate']['DISK'][0]['IMAGE_UNAME']
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
      rows = connect.execute("insert into templates(uid, name, memory, disk_size, cpu, os, host_name, machine, kernel_path, initrd, kernel_args, network_name, sshkey, created_at) values(1, '"+data['vmtemplate']['NAME']+"', '"+data['vmtemplate']['MEMORY']+"', '"+disk_size+"', '', '"+image+"', '"+host_name+"', '"+data['vmtemplate']['OS']['MACHINE']+"', '"+data['vmtemplate']['OS']['KERNEL']+"', '"+data['vmtemplate']['OS']['INITRD']+"', '"+data['vmtemplate']['OS']['KERNEL_CMD']+"', '"+network+"', '"+sshkey+"', '"+time.inspect+"')")
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
          "OS"=>{"MACHINE"=>tem_data[8], "KERNEL_CMD"=>tem_data[11], "KERNEL"=>tem_data[9], "INITRD"=>tem_data[10]},
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
        "UPDATE_TIME"=>rows[0][15],
        "TEMPLATE"=>{
          "OS"=>{
            "MACHINE"=>rows[0][8],
            "KERNEL_CMD"=>rows[0][11],
            "KERNEL"=>rows[0][9],
            "INITRD"=>rows[0][10]
          },
          "MEMORY"=>rows[0][3],
          "DISK_SIZE"=>rows[0][4],
          "CONTEXT" =>
          {
            "SSH_PUBLIC_KEY" => rows[0][13]
          },
          "DISK"=>{
            "IMAGE"=>rows[0][6],
            },
          "NIC" => {
             "NETWORK" => rows[0][12],
          },
           "SCHED_REQUIREMENTS"=> "HOST_NAME=\""+rows[0][7]+"\""
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
      keystone_endpoint = ENV['KEYSTONE_ENDPOINT_WITHOUT_PORT']
      if param["username"] == admin_username && param["password"] == admin_password
        port = 35357
        type = "admin"
        options = {"auth"=>{"tenantName"=> "admin", "passwordCredentials"=>{"username"=> param["username"], "password"=> param["password"]}}}
      else
        port = 5000
        type = "user"
        options = {"auth"=>{"passwordCredentials"=>{"username"=> param["username"], "password"=> param["password"]}}}
      end
      con = Excon.new("#{keystone_endpoint}:#{port}/v2.0/tokens")
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

   def action(id, json)
     action_json = JSON.parse(json)
     if action_json["action"]["perform"] == "instantiate" 
       return instantiate(id, json)
     elsif action_json["action"]["perform"] == "clone"
       return clone(id, json)  
     elsif action_json["action"]["perform"] == "update"
       return update(id, json)  
     end
   end

   def instantiate(id, json)
      @options = {}
      post_data = JSON.parse(json)
      template_id = id.split("-")
      template_json = getImageJson(template_id[0])

      options = {
        "__version__" => 1,
        "disk_template"=> "plain",
        "disks"=> [{"size"=> template_json["DISK_SIZE"]}],
        "beparams"=> {"memory"=> template_json["MEMORY"]},
        "os_type"=> template_json["OS"],
        "mode"=>"create",
        #"nics"=>[{"link"=>"br0", "mac"=>"None", "ip"=>"None", "mode"=>"bridged", "vlan"=>"", "network"=>"blue_lan", "name"=> "None", "bridge"=>"br0"}],
        "nics"=>[{"network"=>template_json['NETWORK'], "ip"=>"pool"}],
        "ip_check"=> false,
        "name_check"=>false,
        "hypervisor"=>template_json['TEMPLATE']['OS']["MACHINE"],
        "hvparams"=> {
          "vnc_bind_address" => "0.0.0.0",
          "kernel_path"=> template_json['TEMPLATE']['OS']['KERNEL'],
          "initrd_path" => template_json['TEMPLATE']['OS']['INITRD'],
          "kernel_args" => template_json['TEMPLATE']['OS']['KERNEL_CMD']
        },
        "instance_name"=> post_data["action"]["params"]["vm_name"]
      }
      if template_json["HOST_NAME"].length > 0
        options["pnode"]=template_json["HOST_NAME"]
      end
      post = @client.call("/2/instances", 'POST', options)
      puts post.inspect 
      entry_details = {"template_id" => template_id[0], "vm_name" => post_data["action"]["params"]["vm_name"], "host" => options["pnode"], "os" => template_json["OS"]}
      instance_entry(post, entry_details)
      #return post
      # end
      post
    end
    
    def instance_entry(options, params)
      job = options.data[:body]
      sleep 2
      job_res = @client.call("/2/jobs/#{job}", 'GET')
      js = JSON.parse(job_res.data[:body])
      puts js["status"]
      if js["status"] != "running"
        rows = connect.execute("insert into vms(user_name, user_id, tenant_name, tenant_id, vm_name, host, template_id, os, result, job_id) values('"+@user_details['username']+"', '"+@user_details['user_id']+"', '"+@user_details['group_name']+"', '"+@user_details['group_id']+"', '"+params['vm_name']+"', '"+params['host']+"', '"+params['template_id']+"', '"+params['os']+"', 'error', '"+ job +"')")
      else
        rows = connect.execute("insert into vms(user_name, user_id, tenant_name, tenant_id, vm_name, host, template_id, os, result, job_id) values('"+@user_details['username']+"', '"+@user_details['user_id']+"', '"+@user_details['group_name']+"', '"+@user_details['group_id']+"', '"+params['vm_name']+"', '"+params['host']+"', '"+params['template_id']+"', '"+params['os']+"', 'success', '"+ job +"')")
      end
    end

    def clone(id, json)
      template_id = id.split("-")
      template_json = getImageJson(template_id[0])
      action_json = JSON.parse(json)
      time = Time.new
      rows = connect.execute("insert into templates(uid, name, memory, disk_size, cpu, os, host_name, machine, kernel_path, initrd, kernel_args, network_name, sshkey, created_at) values(1, '"+action_json["action"]["params"]["name"]+"', '"+template_json["MEMORY"]+"', '"+template_json["DISK_SIZE"]+"', '', '"+template_json["OS"]+"', '"+template_json["HOST_NAME"]+"', '"+template_json['TEMPLATE']['OS']["MACHINE"]+"', '"+template_json['TEMPLATE']['OS']['KERNEL']+"', '"+template_json['TEMPLATE']['OS']['INITRD']+"', '"+template_json['TEMPLATE']['OS']['KERNEL_CMD']+"', '"+template_json['NETWORK']+"', '"+template_json['TEMPLATE']['CONTEXT']['SSH_PUBLIC_KEY']+"', '"+time.inspect+"')")
      {:status => 200}
    end
    
    def update(id, json)
      #action_json = JSON.parse(json)
      action_json = JSON[json]
      time = Time.new      
      template = JSON.parse(action_json["action"]["params"])
            
      host_name = (template['vmtemplate']['SCHED_REQUIREMENTS'].split("="))[1]      
      rows = connect.execute("UPDATE templates SET 
      memory='"+ template["vmtemplate"]["MEMORY"] + 
      "', disk_size='" + template["vmtemplate"]["DISK_SIZE"] + 
      "', os='" + template["vmtemplate"]["DISK"][0]["IMAGE"] + 
      "', host_name='" + host_name + 
      "', machine='" + template["vmtemplate"]["OS"]["MACHINE"] +
      "', kernel_path='" + template["vmtemplate"]["OS"]["KERNEL"] +
      "', initrd='" + template["vmtemplate"]["OS"]["INITRD"] +
      "', kernel_args='" + template["vmtemplate"]["OS"]["KERNEL_CMD"] +
      "', network_name='" + template["vmtemplate"]["NETWORK_NAME"] +
      "', sshkey='" + template["vmtemplate"]["CONTEXT"]["SSH_PUBLIC_KEY"] +   
      "', updated_at='" + time.inspect +    
      "' WHERE id=#{id}")
      {:status => 200}
    end

    end
end 
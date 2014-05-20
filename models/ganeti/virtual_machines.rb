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
  class VirtualMachines
    def initialize(client)
      @path = "/2/instances"
      @client = client
      @VM_METHODS = {
            "resume"     => {"METHOD" => "PUT", "ACTION" => "startup"},
            "stop"       => {"METHOD" => "PUT", "ACTION" => "shutdown"},
            "reboot"     => {"METHOD" => "POST", "ACTION" => "reboot"},
            "reset"      => {"METHOD" => "POST", "ACTION" => "reboot", "options" => {"type" => "hard"}}           
        }
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
        "VM_POOL"=>{
          "VM"=> js}
      }
      json.to_json
    end

    def info(param)
      #@param = param.split("-")
      @param = param
      @cli = @client.call(@path+"/"+@param, 'GET')
      @cli
      #cli = @client.call(@path+"/"+@param+"/info", 'GET')
      #if cli.data[:status].to_i != 200
         #return cli
     # else
       #  job = JSON.parse(cli.data[:body])
        # res = @client.call(@path+"/jobs/"+job, 'GET')
        # return res    
      #end
    end

    def info_json
      json = {
        "VM"=> build_json(@param)
      }
      json.to_json
    end

    def build_json(id=nil, name)
      ins_data = @client.call(@path+"/#{name}", 'GET')
      inst_data = JSON.parse(ins_data.data[:body])
      b_json = {
        "ID"=>inst_data["serial_no"],
        "UID"=>"0",
        "GID"=>"0",
        "UNAME"=>"oneadmin",
        "GNAME"=>"default",
        "NAME"=>name,
        "HOST"=>inst_data["pnode"],
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
        "LAST_POLL"=>"0",
        "STATE"=>inst_data["status"],
        "LCM_STATE"=>"0",
        "RESCHED"=>"0",
        "STIME"=>inst_data["ctime"],
        "ETIME"=>"0",
        "DEPLOY_ID"=>{},
        "MEMORY"=>inst_data["beparams"]["memory"],
        "CPU"=>inst_data["beparams"]["vcpus"],
        "NET_TX"=>"0",
        "NET_RX"=>"0",
        "NIC_IPS"=>inst_data["nic.ips"],
        "OS"=>inst_data["os"],
        "TEMPLATE"=>{
          "AUTOMATIC_REQUIREMENTS"=>"!(PUBLIC_CLOUD = YES) | (PUBLIC_CLOUD = YES & (HYPERVISOR = ec2))",
          "CPU"=>"1",
          "MEMORY"=>"1700",
          "TEMPLATE_ID"=>"1",
          "VMID"=>"48"
        },
        "USER_TEMPLATE"=>{},
        "HISTORY_RECORDS"=>{}
      }
      b_json
    end

    def create(json)
      @options = {}
      post_data = JSON.parse(json)
      template_json = getTemplate(post_data["vm"]["template_id"])     
           
       options = {
        "__version__" => 1, 
        "disk_template"=> "plain", 
        "disks"=> [{"size"=> template_json["DISK_SIZE"]}], 
        "beparams"=> {"memory"=> template_json["MEMORY"]},
        "os_type"=> template_json["OS"],
        "mode"=>"create",
        "nics"=>[{"link"=>"br0", "mac"=>"", "ip"=>"None", "mode"=>"bridged", "vlan"=>"", "network"=>"blue_lan", "name"=> "None", "bridge"=>"br0"}],
        #"nics"=>[{"link"=>"br0", "ip"=>"None", "network"=>"blue_lan", "mode"=>"bridged", "bridge"=>"br0"}],
        "ip_check"=> false,
        "name_check"=>false,
        "hypervisor"=>template_json['TEMPLATE']['OS']["MACHINE"],
        "hvparams"=> {
           "vnc_bind_address" => "0.0.0.0", 
           "kernel_path"=> template_json['TEMPLATE']['OS']['KERNEL'],  
           "initrd_path" => template_json['TEMPLATE']['OS']['INITRD'], 
           "kernel_args" => template_json['TEMPLATE']['OS']['KERNEL_CMD']
           },
        "instance_name"=> post_data["vm"]["vm_name"]
       } 
       if template_json["HOST_NAME"].length > 0
       options["pnode"]=template_json["HOST_NAME"]
       end
      post = @client.call(@path, 'POST', options)
      puts post.inspect
      post
    end

    def getTemplate(id)
      tem = Ganeti::Templates.new(@client)
      json = tem.getImageJson(id)
      json
    end

    def delete(id)
      del = @client.call(@path+"/"+id, 'DELETE')
      del
    end

    def action(id, action_json)
      json = JSON.parse(action_json)
      data = @VM_METHODS[json["action"]["perform"]]
      res = @client.call(@path+"/"+id+"/"+data["ACTION"], data["METHOD"], data["options"])
      res
     end

  end
end 
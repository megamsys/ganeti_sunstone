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
  class VirtualMachines
    def initialize(client, options={})
      @path = "/2/instances"
      @client = client
      @VM_METHODS = {
            "resume"     => {"METHOD" => "PUT", "ACTION" => "startup"},
            "stop"       => {"METHOD" => "PUT", "ACTION" => "shutdown"},
            "shutdown"   => {"METHOD" => "PUT", "ACTION" => "shutdown"},
            "reboot"     => {"METHOD" => "POST", "ACTION" => "reboot"},
            "reset"      => {"METHOD" => "POST", "ACTION" => "reboot", "options" => {"type" => "hard"}},
            "resubmit"   => {"METHOD" => "POST", "ACTION" => "reboot", "options" => {"type" => "full"}}, 
            "cancel"     => {"METHOD" => "DELETE", "ACTION" => "delete"}
         }
      @user_details = options
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      json={}
      #c1 = JSON.parse(@cc.data[:body])
      if ENV['GANETI_USER'] == @user_details['username'] && @user_details["group_name"] == "admin"
        c1 = connect.execute( "select * from vms" )
        if c1.empty?
          json = {
            "VM_POOL"=>{}
          }
        else
          js = c1.map { |c|
            builder(c)
          }
          json = {
            "VM_POOL"=>{
              "VM"=> js}
          }
        end
      else
        c1 = connect.execute( "select * from vms where user_id = '" + @user_details['user_id'] + "'")
        puts c1.length
        if c1.empty?
          json = {
            "VM_POOL"=>{}
          }
        else
          js = c1.map { |c|
            builder(c)
          }
          json = {
            "VM_POOL"=>{
              "VM"=> js}
          }
        end
      end
      json.to_json
    end

    def builder(vm_data)
      b_json = {
        "ID"=>vm_data[0],
        "UID"=>vm_data[2],
        "GID"=>vm_data[4],
        "UNAME"=>vm_data[1],
        "GNAME"=>vm_data[3],
        "NAME"=>vm_data[5],
        "HOST"=>vm_data[6],
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
        #"STATE"=>inst_data["status"],
        "STATE"=>"",
        "LCM_STATE"=>"0",
        "RESCHED"=>"0",
        "STIME"=>"",
        "ETIME"=>"0",
        "DEPLOY_ID"=>{},
        "MEMORY"=>0,
        "CPU"=>0,
        "NET_TX"=>"0",
        "NET_RX"=>"0",
        "NIC_IPS"=>"",
        "OS"=>vm_data[8],
        "TEMPLATE"=>{},
        "USER_TEMPLATE"=>{},
        "HISTORY_RECORDS"=>{}
      }
      b_json
    end

    def info(param)
      #@param = param.split("-")
      @param = param
      @cli = @client.call("/2/info", 'GET')
      @cli
    #@cli = @client.call(@path+"/"+@param, 'GET')
    # @cli
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
        #"VM"=> {}
      }
      json.to_json
    end

    def build_json(id=nil, name)
      #ins_data = @client.call(@path+"/#{name}", 'GET')
      #inst_data = JSON.parse(ins_data.data[:body])
      c1 = connect.execute( "select * from vms where vm_name = '" + name + "'")
      template = getTemplate(c1[0][7].to_s)
      if c1[0][9] != "success"
        return get_error_info(name, template, c1[0][10])
      else
        return get_success_info(name, template, c1[0][10])
      end
    end

    def get_error_info(name, template, job_id)
      info = get_error_job(name, job_id)
      b_json = {
        "ID"=>0,
        "UID"=>@user_details['user_id'],
        "GID"=>@user_details['group_id'],
        "UNAME"=>@user_details['username'],
        "GNAME"=>@user_details['group_name'],
        "NAME"=>name,
        "HOST"=>'ERROR',
        "HOST_GROUP"=>'ERROR',
        "UUID"=> 'ERROR',
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
        "STATE"=>'ERROR',
        "CONFIG_STATE"=>'ERROR',
        "LCM_STATE"=>"0",
        "RESCHED"=>"0",
        "STIME"=>'ERROR',
        "MTIME"=>'ERROR',
        "ETIME"=>"0",
        "DEPLOY_ID"=>{},
        "MEMORY"=>'ERROR',
        "CPU"=>'ERROR',
        "NET_TX"=>"0",
        "NET_RX"=>"0",
        "NIC_IPS"=>"",
        "NICS"=>[],
        "ALLOCATED_PORT"=>'ERROR',
        "HYPERVISOR"=>'ERROR',
        "OS"=>'ERROR',
        "DISKS"=> [{
            "DISK_TEMPLATE"=> 'ERROR',
            "SIZE"=> 'ERROR',
            "ACCESS_MODE"=> 'ERROR',
            "LOGICAL_ID"=> 'ERROR'
          }],
        "TEMPLATE"=>{
          "NAME"=> template["NAME"],
          "CPU"=> template["CPU"],
          "MEMORY"=>template["MEMORY"],
          "OPERATING_SYSTEM"=>template["OS"],
          "DISK_SIZE"=>template["DISK_SIZE"],
          "HOST_NAME"=>template["HOST_NAME"],
          "MACHINE"=>template["TEMPLATE"]["OS"]["MACHINE"],
          "KERNEL_CMD"=>template["TEMPLATE"]["OS"]["KERNEL_CMD"],
          "KERNEL"=>template["TEMPLATE"]["OS"]["KERNEL"],
          "INITRD"=>template["TEMPLATE"]["OS"]["INITRD"],
          "REGTIME"=>template["REGTIME"]
        },
        "LOG"=>info["opresult"][0][1],
        "USER_TEMPLATE"=>{},
        "HISTORY_RECORDS"=>{}
      }
      b_json
    end

    def get_success_info(name, template, job_id)
      info = get_info(name, job_id)
      c1 = connect.execute( "select * from vms where vm_name = '" + name + "'")
      template = getTemplate(c1[0][7].to_s)
      b_json = {
        "ID"=>info["opresult"][0]["#{name}"]["serial_no"],
        "UID"=>@user_details['user_id'],
        "GID"=>@user_details['group_id'],
        "UNAME"=>@user_details['username'],
        "GNAME"=>@user_details['group_name'],
        "NAME"=>name,
        "HOST"=>info["opresult"][0]["#{name}"]["pnode"],
        "HOST_GROUP"=>info["opresult"][0]["#{name}"]["pnode_group_name"],
        "UUID"=> info["opresult"][0]["#{name}"]["uuid"],
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
        "STATE"=>info["opresult"][0]["#{name}"]["run_state"],
        "CONFIG_STATE"=>info["opresult"][0]["#{name}"]["config_state"],
        "LCM_STATE"=>"0",
        "RESCHED"=>"0",
        "STIME"=>info["opresult"][0]["#{name}"]["ctime"],
        "MTIME"=>info["opresult"][0]["#{name}"]["mtime"],
        "ETIME"=>"0",
        "DEPLOY_ID"=>{},
        "MEMORY"=>info["opresult"][0]["#{name}"]["be_instance"]["maxmem"],
        "CPU"=>info["opresult"][0]["#{name}"]["be_actual"]["vcpus"],
        "NET_TX"=>"0",
        "NET_RX"=>"0",
        "NIC_IPS"=>"",
        "NICS"=>info["opresult"][0]["#{name}"]["nics"],
        "ALLOCATED_PORT"=>info["opresult"][0]["#{name}"]["network_port"],
        "HYPERVISOR"=>info["opresult"][0]["#{name}"]["hypervisor"],
        "OS"=>info["opresult"][0]["#{name}"]["os"],
        "DISKS"=> info["opresult"][0]["#{name}"]["disks"].map { |disk| disk_collect(disk) },
        "TEMPLATE"=>{
          "NAME"=> template["NAME"],
          "CPU"=> template["CPU"],
          "MEMORY"=>template["MEMORY"],
          "OPERATING_SYSTEM"=>template["OS"],
          "DISK_SIZE"=>template["DISK_SIZE"],
          "HOST_NAME"=>template["HOST_NAME"],
          "MACHINE"=>template["TEMPLATE"]["OS"]["MACHINE"],
          "KERNEL_CMD"=>template["TEMPLATE"]["OS"]["KERNEL_CMD"],
          "KERNEL"=>template["TEMPLATE"]["OS"]["KERNEL"],
          "INITRD"=>template["TEMPLATE"]["OS"]["INITRD"],
          "REGTIME"=>template["REGTIME"]
        },
        "LOG"=>[],
        "USER_TEMPLATE"=>{},
        "HISTORY_RECORDS"=>{}
      }
      b_json
    end

    def disk_collect(disk)
      js = {
        "DISK_TEMPLATE"=> disk["dev_type"],
        "SIZE"=> disk["size"],
        "ACCESS_MODE"=> disk["mode"],
        "LOGICAL_ID"=> "#{disk["logical_id"][0]}" +"/" + "#{disk["logical_id"][1]}"
      }
    end

    def get_error_job(name, job_id)
      ins_data = @client.call("/2/jobs/#{job_id}", 'GET')
      JSON.parse(ins_data.data[:body])
    #ins_data.data[:body]
    end

    def get_info(name, job_id)
      ins_data = @client.call(@path+"/#{name}/info", 'GET')
      job = ins_data.data[:body]
      sleep 2
      ins_data = @client.call("/2/jobs/#{job}", 'GET')
      JSON.parse(ins_data.data[:body])
    #ins_data.data[:body]
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
        "instance_name"=> post_data["vm"]["vm_name"]
      }
      if template_json["HOST_NAME"].length > 0
        options["pnode"]=template_json["HOST_NAME"]
      end
      post = @client.call(@path, 'POST', options)
      puts post.inspect
      # if post[:status].to_i != 200
      #return post
      #else
      entry_details = {"template_id" => post_data["vm"]["template_id"], "vm_name" => post_data["vm"]["vm_name"], "host" => options["pnode"], "os" => template_json["OS"]}
      instance_entry(post, entry_details)
      #return post
      # end
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

    def purge(id)
      connect.execute("DELETE FROM vms WHERE vm_name = '" + id +"';")
    end

    def action(id, action_json)
      json = JSON.parse(action_json)
      data = @VM_METHODS[json["action"]["perform"]]
      if data["ACTION"] == "delete"
        purge(id)
        return delete(id)
      else
        res = @client.call(@path+"/"+id+"/"+data["ACTION"], data["METHOD"], data["options"])
      return res
      end
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

    def connect
      require 'sqlite3'
      db = SQLite3::Database.new("ganeti.db")
      db.execute("PRAGMA foreign_keys = ON;")
      db
    end

  end
end 
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

require 'common/CloudServer'
require 'OpenNebulaJSON'

include OpenNebulaJSON

require 'OpenNebulaVNC'
require 'OpenNebulaJSON/JSONUtils'

include JSONUtils
class SunstoneServer < CloudServer
  # FLAG that will filter the elements retrieved from the Pools
  POOL_FILTER = Pool::INFO_ALL

  # Secs to sleep between checks to see if image upload to repo is finished
  IMAGE_POLL_SLEEP_TIME = 5
  def initialize(client, config, logger)
    super(config, logger)
    @client = client
  end

  ############################################################################
  #
  ############################################################################
  def get_pool(kind,gid, client=nil, options)
    client = @client if !client
    if gid == "0"
      user_flag = Pool::INFO_ALL
    else
      user_flag = POOL_FILTER
    end
    puts "----------------------get pool----------------------------"
    pool = case kind
    when "group"      then Ganeti::Tenants.new(client)
    when "host"       then Ganeti::Hosts.new(client)
    when "image"      then Ganeti::Images.new(client)
    when "vmtemplate" then Ganeti::Templates.new(client)
    when "vm"         then Ganeti::VirtualMachines.new(client, options)
    when "vnet"       then Ganeti::VirtualNetworks.new(client)
    when "user"       then Ganeti::User.new(client)
    when "zone"       then Ganeti::Zones.new(client)
    when "hgroup"     then Ganeti::HostGroups.new(client)
    else
    error = Error.new("Error: #{kind} resource not supported")
    return [404, error.to_json]
    end

    res = pool.call
    if res.data[:status].to_i != 200
      return [500, pool.to_json]
    else
      return [200, pool.to_json]
    end

  end

  ############################################################################
  #
  ############################################################################
  def get_resource(kind, id, options)
    #resource = retrieve_resource(kind, id)
     puts "----------------------get resourse----------------------------"
    resource = case kind
    when "group"     then Ganeti::Tenants.new(@client)
    when "host"       then Ganeti::Hosts.new(@client)
    when "image"      then Ganeti::Images.new(@client)
    when "vmtemplate" then Ganeti::Templates.new(@client)
    when "vm"         then Ganeti::VirtualMachines.new(@client, options)
    when "vnet"       then Ganeti::VirtualNetworks.new(@client)
    when "user"       then Ganeti::User.new(@client)
    when "zone"       then Ganeti::Zones.new(@client)
    when "hgroup"     then Ganeti::HostGroups.new(@client)
    else
    error = Error.new("Error: #{kind} resource not supported")
    return error
    end

    res = resource.info(id)
    if res.data[:status].to_i != 200
      return [500, resource.info_json]
    else
      return [200, resource.info_json]
    end

  end

  ############################################################################
  #
  ############################################################################
  def get_template(kind,id)
     puts "----------------------get template----------------------------"
    resource = retrieve_resource(kind,id)
    if OpenNebula.is_error?(resource)
      return [404, resource.to_json]
    else
      template_str = resource.template_str(true)
      return [200, {:template => template_str}.to_json]
    end
  end

  ############################################################################
  #
  ############################################################################
  def create_resource(kind, json, options)
    resource = case kind
    when "group"      then Ganeti::Tenants.new(@client)
    when "host"       then Ganeti::Hosts.new(@client)
    when "image"      then Ganeti::Images.new(@client)
    when "vmtemplate" then Ganeti::Templates.new(@client)
    when "vm"         then Ganeti::VirtualMachines.new(@client, options)
    when "vnet"       then Ganeti::VirtualNetworks.new(@client)
    when "user"       then Ganeti::User.new(@client)
    when "zone"       then Ganeti::Zones.new(@client)
    when "hgroup"     then Ganeti::HostGroups.new(@client)
    else
    error = Error.new("Error: #{kind} resource not supported")
    return error
    end    
    res = resource.create(json)
    resource.call
    if res[:status].to_i != 200
      return [500, resource.to_json]
    else
    #resource.info
      return [201, resource.to_json]
    end
  end

  ############################################################################
  #
  ############################################################################
  def upload(template, file_path)
    image_hash = parse_json(template, 'image')
    if OpenNebula.is_error?(image_hash)
      return [500, image_hash.to_json]
    end

    image_hash['PATH'] = file_path

    ds_id = parse_json(template, 'ds_id')
    if OpenNebula.is_error?(ds_id)
      return [500, ds_id.to_json]
    end

    new_template = {
      :image => image_hash,
      :ds_id => ds_id,
    }.to_json

    image = ImageJSON.new(Image.build_xml, @client)

    rc = image.create(new_template)

    if OpenNebula.is_error?(rc)
      return [500, rc.to_json]
    end

    image.info
    #wait until image is ready to return
    while (image.state_str == 'LOCKED') && (image['RUNNING_VMS'] == '0') do
      sleep IMAGE_POLL_SLEEP_TIME
      image.info
    end
    return [201, image.to_json]
  end

  ############################################################################
  #
  ############################################################################
  def delete_resource(kind, id, options)
    resource = retrieve_resource(kind, id, options)   

    res = resource.delete(id)
    resource.call
    if res[:status].to_i != 200
      return [500, resource.to_json]
    else
    #resource.info
      resource.purge(id)
      return [201, resource.to_json]
    end
  end

  ############################################################################
  #
  ############################################################################
  def perform_action(kind, id, action_json, options)
    #resource = retrieve_resource(kind, id)
     puts "----------------------perform action----------------------------"
    resource = case kind
    when "group"     then Ganeti::Tenants.new(@client)
    when "host"       then Ganeti::Hosts.new(@client)
    when "image"      then Ganeti::Images.new(@client)
    when "vmtemplate" then Ganeti::Templates.new(@client, options)
    when "vm"         then Ganeti::VirtualMachines.new(@client, options)
    when "vnet"       then Ganeti::VirtualNetworks.new(@client)
    when "user"       then Ganeti::User.new(@client)
    when "zone"       then Ganeti::Zones.new(@client)
    when "hgroup"     then Ganeti::HostGroups.new(@client)
    else
    error = Error.new("Error: #{kind} resource not supported")
    return error
    end
    puts kind
    puts id
    puts action_json
    res = resource.action(id, action_json)   
   #resource.call
   resource.info(id)
   puts res.inspect
    if res[:status].to_i != 200
      return [500, resource.info_json]
    else
    #resource.info
      return [200, resource.info_json]
    end
  end

  ############################################################################
  # Unused
  ############################################################################
  def get_vm_log(id)
    resource = retrieve_resource("vm", id)
    if OpenNebula.is_error?(resource)
      return [404, nil]
    else
      if !ONE_LOCATION
        vm_log_file = LOG_LOCATION + "/#{id}.log"
      else
        vm_log_file = LOG_LOCATION + "/vms/#{id}/vm.log"
      end

      begin
        log = File.read(vm_log_file)
      rescue Exception => e
        msg = "Log for VM #{id} not available"
        return [200, {:vm_log => msg}.to_json]
      end

      return [200, {:vm_log => log}.to_json]
    end
  end

  ########################################################################
  # VNC
  ########################################################################
  def startvnc(id, vnc)
    resource = retrieve_resource("vm", id)
    if OpenNebula.is_error?(resource)
      return [404, resource.to_json]
    end

    return vnc.proxy(resource, id)
  end

  ########################################################################
  # Accounting & Monitoring
  ########################################################################
  def get_pool_monitoring(resource, meters)
    #pool_element
    pool = case resource
    when "vm", "VM"
      VirtualMachinePool.new(@client)
    when "host", "HOST"
      HostPool.new(@client)
    else
    error = Error.new("Monitoring not supported for #{resource}")
    return [200, error.to_json]
    end

    meters_a = meters.split(',')

    rc = pool.monitoring(meters_a)

    if OpenNebula.is_error?(rc)
      error = Error.new(rc.message)
      return [500, error.to_json]
    end

    rc[:resource] = resource

    return [200, rc.to_json]
  end

  def get_resource_monitoring(id, resource, meters)
    pool_element = case resource
    when "vm", "VM"
      VirtualMachine.new_with_id(id, @client)
    when "host", "HOST"
      Host.new_with_id(id, @client)
    else
    error = Error.new("Monitoring not supported for #{resource}")
    return [403, error.to_json]
    end

    meters_a = meters.split(',')

    rc = pool_element.monitoring(meters_a)

    if OpenNebula.is_error?(rc)
      error = Error.new(rc.message)
      return [500, error.to_json]
    end

    meters_h = Hash.new
    meters_h[:resource]   = resource
    meters_h[:id]         = id
    meters_h[:monitoring] = rc

    return [200, meters_h.to_json]
  end

  # returns a { monitoring : meter1 : [[ts1, agg_value],[ts2, agg_value]...]
  #                          meter2 : [[ts1, agg_value],[ts2, agg_value]...]}
  # with this information we can paint historical graphs of usage
  def get_user_accounting(options)
    uid      = options[:id].to_i
    tstart   = options[:start].to_i
    tend     = options[:end].to_i
    interval = options[:interval].to_i
    meters   = options[:monitor_resources]
    gid      = options[:gid].to_i

    acct_options = {:start_time => tstart,
      :end_time => tend}

    # If we want acct per group, we ask for all VMs visible to user
    # and then filter by group.
    if gid
      uid = Pool::INFO_ALL
      acct_options[:group] = gid
    end

    # Init results and request accounting
    result   = {}
    meters_a = meters.split(',')
    meters_a.each do | meter |
      result[meter] = []
    end
    pool     = VirtualMachinePool.new(@client)
    acct_xml = pool.accounting_xml(uid, acct_options)

    if OpenNebula.is_error?(acct_xml)
      error = Error.new(acct_xml.message)
      return [500, error.to_json]
    end

    xml = XMLElement.new
    xml.initialize_xml(acct_xml, 'HISTORY_RECORDS')

    # We aggregate the accounting values for each interval withing
    # the given timeframe
    while tstart < tend

      tstep = tstart + interval
      count = Hash.new

      # We count machines which have started before the end of
      # this interval AND have not finished yet OR machines which
      # have started before the end of this interval AND
      # have finished anytime after the start of this interval
      xml.each("HISTORY[STIME<=#{tstep} and ETIME=0 or STIME<=#{tstep} and ETIME>=#{tstart}]") do |hr|

        meters_a.each do | meter |
        count[meter] ||= 0
          count[meter] += hr["VM/#{meter}"].to_i if hr["VM/#{meter}"]
        end
      end

      # We have aggregated values for this interval
      # Then we just add them to the results along with a timestamp
      count.each do | mname, mcount |
        result[mname] << [tstart, mcount]
      end

      tstart = tstep
    end

    return [200, {:monitoring => result}.to_json]
  end

  private

  ############################################################################
  #
  ############################################################################
  def retrieve_resource(kind, id, options= {})
=begin
resource = case kind
when "group"      then GroupJSON.new_with_id(id, @client)
when "cluster"    then ClusterJSON.new_with_id(id, @client)
when "host"       then HostJSON.new_with_id(id, @client)
when "image"      then ImageJSON.new_with_id(id, @client)
when "vmtemplate" then TemplateJSON.new_with_id(id, @client)
when "vm"         then VirtualMachineJSON.new_with_id(id, @client)
when "vnet"       then VirtualNetworkJSON.new_with_id(id, @client)
when "user"       then UserJSON.new_with_id(id, @client)
when "acl"        then AclJSON.new_with_id(id, @client)
when "datastore"  then DatastoreJSON.new_with_id(id, @client)
when "zone"       then ZoneJSON.new_with_id(id, @client)
else
error = Error.new("Error: #{kind} resource not supported")
return error
end
=end
    resource = case kind
    when "group"      then Ganeti::Tenants.new(@client)
    when "host"       then Ganeti::Hosts.new(@client)
    when "image"      then Ganeti::Images.new(@client)
    when "vmtemplate" then Ganeti::Templates.new(@client)
    when "vm"         then Ganeti::VirtualMachines.new(@client, options)
    when "vnet"       then Ganeti::VirtualNetworks.new(@client)
    when "user"       then Ganeti::User.new(@client)
    when "zone"       then Ganeti::Zones.new(@client)
    when "hgroup"     then Ganeti::HostGroups.new(@client)
    else
    error = Error.new("Error: #{kind} resource not supported")
    return error
    end

    resource

  end
end

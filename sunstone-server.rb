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

ONE_LOCATION = ENV["MEGANETI_HOME_URL"]
if !ONE_LOCATION
  LOG_LOCATION = "/var/log/one"
  VAR_LOCATION = "/var/lib/one"
  ETC_LOCATION = "/etc/one"
  SHARE_LOCATION = "/usr/share/one"
  RUBY_LIB_LOCATION = "/usr/lib/one/ruby"
else
  VAR_LOCATION = ONE_LOCATION + "/var"
  LOG_LOCATION = ONE_LOCATION + "/logs"
  ETC_LOCATION = ONE_LOCATION + "/etc"
  SHARE_LOCATION = ONE_LOCATION + "/share"
  RUBY_LIB_LOCATION = ONE_LOCATION+"/lib/ruby"
end

#SUNSTONE_AUTH             = "/var/lib/ganeti/sunstone_auth"
SUNSTONE_AUTH             = "config/sunstone_auth"
#SUNSTONE_LOG              = "/var/log/one/sunstone.log"
SUNSTONE_LOG              = "logs/sunstone.log"
CONFIGURATION_FILE        = "config/sunstone-server.conf"

PLUGIN_CONFIGURATION_FILE = "config/sunstone-plugins.yaml"

SUNSTONE_ROOT_DIR = File.dirname(__FILE__)

$: << RUBY_LIB_LOCATION
$: << RUBY_LIB_LOCATION+'/cloud'
$: << SUNSTONE_ROOT_DIR
$: << SUNSTONE_ROOT_DIR+'/models'

SESSION_EXPIRE_TIME = 60*60

DISPLAY_NAME_XPATH = 'TEMPLATE/SUNSTONE_DISPLAY_NAME'

##############################################################################
# Required libraries
##############################################################################
require 'rubygems'
require 'erb'
require 'yaml'
require 'common/CloudAuth'
require 'SunstoneServer'
require 'SunstoneViews'
require "sinatra"
require "json"

#require "models/users"

##############################################################################
# Configuration
##############################################################################

begin
  $conf = YAML.load_file(CONFIGURATION_FILE)
rescue Exception => e
  STDERR.puts "Error parsing config file #{CONFIGURATION_FILE}: #{e.message}"
  exit 1
end

$conf[:debug_level] ||= 3

CloudServer.print_configuration($conf)

#Sinatra configuration

set :config, $conf
set :bind, $conf[:host]
set :port, $conf[:port]

case $conf[:sessions]
when 'memory', nil
  use Rack::Session::Pool, :key => 'sunstone'
when 'memcache'
  memcache_server=$conf[:memcache_host]+':'<<
  $conf[:memcache_port].to_s

  STDERR.puts memcache_server

  use Rack::Session::Memcache,
        :memcache_server => memcache_server,
        :namespace => $conf[:memcache_namespace]
else
STDERR.puts "Wrong value for :sessions in configuration file"
exit(-1)
end

use Rack::Deflater

# Enable logger

include CloudLogger
logger=enable_logging(SUNSTONE_LOG, $conf[:debug_level].to_i)

begin
  ENV["ONE_CIPHER_AUTH"] = SUNSTONE_AUTH
  $cloud_auth = CloudAuth.new($conf, logger)
rescue => e
  logger.error {
    "Error initializing authentication system" }
  logger.error { e.message }
  exit -1
end

set :cloud_auth, $cloud_auth

$views_config = SunstoneViews.new

#start VNC proxy

$vnc = MegamVNC.new($conf, logger)

configure do
  set :run, false
  set :vnc, $vnc
  set :erb, :trim => '-'
end

DEFAULT_TABLE_ORDER = "desc"
require 'ganeti'

##############################################################################
# Helpers
##############################################################################
helpers do
  def authorized?
    session[:ip] && session[:ip]==request.ip ? true : false
  end

  def build_session
    begin
      result = $cloud_auth.auth(request.env, params)
    rescue Exception => e
      logger.error { e.message }
      return [500, ""]
    end

    if result.nil?
      logger.info { "Unauthorized login attempt" }
      return [401, ""]
    else
      client  = $cloud_auth.client(nil, nil, result)
      user_id = Ganeti::User::SELF
      user_initialize    = Ganeti::User.new(client)
      user = user_initialize.tenant_info(result)
      #rc = user.info
      #logger.info { rc.inspect }
      #if OpenNebula.is_error?(rc)
      #    logger.error { rc.message }
      #    return [500, ""]
      # end
      session[:user]         = user["NAME"]
      session[:user_id]      = user["ID"]
      session[:user_gid]     = user["GID"]
      session[:user_gname]   = user["GNAME"]
      session[:ip]           = request.ip
      session[:remember]     = params["remember"]
      session[:display_name] = user[DISPLAY_NAME_XPATH] || user["NAME"]

      #User IU options initialization
      #Load options either from user settings or default config.
      # - LANG
      # - WSS CONECTION
      # - TABLE ORDER
      if user['TEMPLATE/LANG']
        session[:lang] = user['TEMPLATE/LANG']
      else
        session[:lang] = $conf[:lang]
      end
      if user['TEMPLATE/VNC_WSS']
        session[:vnc_wss] = user['TEMPLATE/VNC_WSS']
      else
        wss = $conf[:vnc_proxy_support_wss]
        #limit to yes,no options
        session[:vnc_wss] = (wss == true || wss == "yes" || wss == "only" ?
        "yes" : "no")
      end
      if user['TEMPLATE/TABLE_ORDER']
        session[:table_order] = user['TEMPLATE/TABLE_ORDER']
      else
        session[:table_order] = $conf[:table_order] || DEFAULT_TABLE_ORDER
      end
      if user['TEMPLATE/DEFAULT_VIEW']
        session[:default_view] = user['TEMPLATE/DEFAULT_VIEW']
      else
        session[:default_view] = $views_config.available_views(session[:user], session[:user_gname]).first
      end

      #end user options

      if params[:remember] == "true"
        env['rack.session.options'][:expire_after] = 30*60*60*24-1
      end
    
      session[:zone_name] = 'Ganeti'
      return [204, ""]
    end
  end

  def destroy_session
    session.clear
    return [204, ""]
  end

  def cloud_view_instance_types
    $conf[:instance_types] || {}
  end
end

before do
  cache_control :no_store
  content_type 'application/json', :charset => 'utf-8'
  unless request.path=='/login' || request.path=='/' || request.path=='/vnc' 
    if request.path != '/keys/template'
    halt 401 unless authorized?
    end
  end

  if env['HTTP_ZONE_NAME']
    @client=$cloud_auth.client(session[:user])
    zpool = Ganeti::Zones.new(@client)
    #zpool = ZonePoolJSON.new(@client)

    rc = zpool.info
     res = zpool.call
      if res.data[:status].to_i != 200
      return [500, zpool.to_json]   
    end
  
  end
  options = {}
  @client=$cloud_auth.client(session[:user],  #change verify error login page
  session[:active_zone_endpoint], options)

  @SunstoneServer = SunstoneServer.new(@client,$conf,logger)
end

after do
  unless request.path=='/login' || request.path=='/' || request.path=='/'
    unless session[:remember] == "true"
      if params[:timeout] == "true"
        env['rack.session.options'][:defer] = true
      else
        env['rack.session.options'][:expire_after] = SESSION_EXPIRE_TIME
      end
    end
  end
end


##############################################################################
# HTML Requests
##############################################################################
get '/' do
  content_type 'text/html', :charset => 'utf-8'
  if !authorized?
    return erb :login
  end

  response.set_cookie("one-user", :value=>"#{session[:user]}")
  erb :index
end

get '/login' do
  content_type 'text/html', :charset => 'utf-8'
  if !authorized?
    erb :login
  end
end

get '/vnc' do
  content_type 'text/html', :charset => 'utf-8'
  if !authorized?
    erb :login
  else
    erb :vnc
  end
end

##############################################################################
# Login
##############################################################################
post '/login' do
  build_session
end

post '/logout' do
  destroy_session
end

##############################################################################
# User configuration and VM logs
##############################################################################

get '/config' do
  uconf = {
    :user_config => {
      :lang => session[:lang],
      :vnc_wss  => session[:vnc_wss],
    },
    :system_config => {
      :marketplace_url => $conf[:marketplace_url],
   #   :vnc_proxy_port => $vnc.proxy_port
    }
  }

  [200, uconf.to_json]
end

post '/config' do
  @SunstoneServer.perform_action('user',
  OpenNebula::User::SELF,
  request.body.read)

  user = OpenNebula::User.new_with_id(
  OpenNebula::User::SELF,
  $cloud_auth.client(session[:user]))

  rc = user.info
  if OpenNebula.is_error?(rc)
    logger.error { rc.message }
    error 500, ""
  end

  session[:lang]         = user['TEMPLATE/LANG'] if user['TEMPLATE/LANG']
  session[:vnc_wss]      = user['TEMPLATE/VNC_WSS'] if user['TEMPLATE/VNC_WSS']
  session[:default_view] = user['TEMPLATE/DEFAULT_VIEW'] if user['TEMPLATE/DEFAULT_VIEW']
  session[:table_order]  = user['TEMPLATE/TABLE_ORDER'] if user['TEMPLATE/TABLE_ORDER']
  session[:display_name] = user[DISPLAY_NAME_XPATH] || user['NAME']

  [200, ""]
end

get '/vm/:id/log' do
 # @SunstoneServer.get_vm_log(params[:id])
end

##############################################################################
# Accounting & Monitoring
##############################################################################

get '/:resource/monitor' do
  @SunstoneServer.get_pool_monitoring(
  params[:resource],
  params[:monitor_resources])
end

get '/user/:id/monitor' do
  @SunstoneServer.get_user_accounting(params)
end

get '/group/:id/monitor' do
  params[:gid] = params[:id]
  @SunstoneServer.get_user_accounting(params)
end

get '/:resource/:id/monitor' do
  @SunstoneServer.get_resource_monitoring(
  params[:id],
  params[:resource],
  params[:monitor_resources])
end

##############################################################################
# Marketplace
##############################################################################
get '/marketplace' do
  @SunstoneServer.get_appliance_pool
end

get '/marketplace/:id' do
  @SunstoneServer.get_appliance(params[:id])
end

##############################################################################
# GET Pool information
##############################################################################
get '/:pool' do
  zone_client = nil
  user_details = {"username" => session[:user], "user_id" => session[:user_id], "group_name" => session[:user_gname], "group_id" => session[:user_gid]}     
  @SunstoneServer.get_pool(params[:pool], session[:user_gid], zone_client, user_details) 
end

##############################################################################
# GET Resource information
##############################################################################

get '/:resource/:id/template' do
  @SunstoneServer.get_template(params[:resource], params[:id])
end

get '/keys/template' do
  template = Ganeti::Templates.new
  template.get_sshkey(params)
end

get '/:resource/:id' do
  user_details = {"username" => session[:user], "user_id" => session[:user_id], "group_name" => session[:user_gname], "group_id" => session[:user_gid]}     
  @SunstoneServer.get_resource(params[:resource], params[:id], user_details)
end

##############################################################################
# Delete Resource
##############################################################################
delete '/:resource/:id' do
    user_details = {"username" => session[:user], "user_id" => session[:user_id], "group_name" => session[:user_gname], "group_id" => session[:user_gid]}     
   @SunstoneServer.delete_resource(params[:resource], params[:id], user_details)
end

##############################################################################
# Upload image
##############################################################################
post '/upload'do

  tmpfile = nil
  rackinput = request.env['rack.input']

  if (rackinput.class == Tempfile)
  tmpfile = rackinput
  elsif rackinput.respond_to?('read')
    tmpfile = Tempfile.open('sunstone-upload')
  tmpfile.write rackinput.read
  tmpfile.flush
  else
    logger.error { "Unexpected rackinput class #{rackinput.class}" }
    [500, ""]
  end

  if tmpfile.size == 0
    [500, OpenNebula::Error.new("There was a problem uploading the file, " \
                "please check the permissions on the file").to_json]
  else
    @SunstoneServer.upload(params[:img], tmpfile.path)
  end
end

##############################################################################
# Create a new Resource
##############################################################################
post '/:pool' do
  user_details = {"username" => session[:user], "user_id" => session[:user_id], "group_name" => session[:user_gname], "group_id" => session[:user_gid]}     
  @SunstoneServer.create_resource(params[:pool], request.body.read, user_details)
end

##############################################################################
# Start VNC Session for a target VM
##############################################################################
post '/vm/:id/startvnc' do
  vm_id = params[:id]
  @SunstoneServer.startvnc(vm_id, $vnc)
end

##############################################################################
# Perform an action on a Resource
##############################################################################
post '/:resource/:id/action' do
    user_details = {"username" => session[:user], "user_id" => session[:user_id], "group_name" => session[:user_gname], "group_id" => session[:user_gid]}     
   @SunstoneServer.perform_action(params[:resource], params[:id], request.body.read, user_details)
end
Sinatra::Application.run! if(!defined?(WITH_RACKUP))


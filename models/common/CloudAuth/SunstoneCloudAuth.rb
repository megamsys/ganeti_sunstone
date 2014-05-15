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
require 'UserDB'
require "excon"

module SunstoneCloudAuth
  def do_auth(env, params={})
    auth = Rack::Auth::Basic::Request.new(env)
    username, password = auth.credentials
    if auth.provided? && auth.basic?
      username, password = auth.credentials
      # require 'sqlite3'
      #db = SQLite3::Database.new( "ganeti.db" )
      #rows = db.execute( "select * from users where user_name = '" + username +"'" )
      #one_pass = rows[0][2]
      #one_pass = get_password(username, 'core')
      #if one_pass && one_pass == Digest::SHA1.hexdigest(password)
      @options={}
      port = 0
      type = ''
      options={}
      tenant={}
      admin_username = ENV['GANETI_USER']
      admin_password = ENV['GANETI_PASSWORD']
      puts "---------------------------------------------------------------------------"
      puts username
      puts password
      puts "------------------admin------"
      puts admin_username
      puts admin_password
      puts "---------------------------------------------------------------------------"
      if username == admin_username && password == admin_password
        port = 35357
        type = "admin"
        options = {"auth"=>{"tenantName"=> "admin", "passwordCredentials"=>{"username"=> username, "password"=> password}}}
      else
        port = 5000
        type = "user"
        options = {"auth"=>{"passwordCredentials"=>{"username"=> username, "password"=> password}}}
      end
      puts "---------------------------------------------------------------------------"
      puts port
      puts type
      puts options
      puts "http://192.168.2.3:#{port}/v2.0/tokens"
      con = Excon.new("http://192.168.2.3:#{port}/v2.0/tokens")
      @options[:method]='POST'
      @options[:headers]={ "Content-Type" => "application/json"}      
      @options[:body]=options.to_json
      res = con.request(@options)
      puts res.inspect
      con.reset

      #if one_pass && one_pass == password
      if res[:status] == 200
        json = JSON.parse(res.data[:body])
      return {
        "username" => username, 
        "token" => json['access']['token']['id'], 
        "type" => type, 
        "tenant" => json["access"]["token"]["tenant"],
        "user_id" => json["access"]["user"]["id"]
        }
      end
    end

    return nil
  end
end
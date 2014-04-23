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

module SunstoneCloudAuth
    def do_auth(env, params={})
        auth = Rack::Auth::Basic::Request.new(env)           
        if auth.provided? && auth.basic?
            username, password = auth.credentials  
            require 'sqlite3'
            db = SQLite3::Database.new( "ganeti.db" )
            rows = db.execute( "select * from users where user_name = '" + username +"'" )           
            one_pass = rows[0][2]
            #one_pass = get_password(username, 'core')                   
            #if one_pass && one_pass == Digest::SHA1.hexdigest(password)
            if one_pass && one_pass == password
                return username
            end
        end

        return nil
    end
end
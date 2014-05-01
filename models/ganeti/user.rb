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
    class User 
        #######################################################################
        # Constants and Class Methods
        #######################################################################
     
        USER_METHODS = {
            :info     => "user.info",
            :allocate => "user.allocate",
            :delete   => "user.delete",
            :passwd   => "user.passwd",
            :chgrp    => "user.chgrp",
            :addgroup => "user.addgroup",
            :delgroup => "user.delgroup",
            :update   => "user.update",
            :chauth   => "user.chauth",
            :quota    => "user.quota"
        }

        SELF      = -1
      
        # Driver name for default core authentication
        CORE_AUTH = "core"

        # Driver name for default core authentication
        CIPHER_AUTH = "server_cipher"

        # Driver name for ssh authentication
        SSH_AUTH  = "ssh"

        # Driver name for x509 authentication
        X509_AUTH = "x509"

        # Driver name for x509 proxy authentication
        X509_PROXY_AUTH = "x509_proxy"

      
        # Class constructor
        def initialize(client)

            @client = client
        end

        #######################################################################
        # XML-RPC Methods for the User Object
        #######################################################################

        # Retrieves the information of the given User.
        def info(username)
           # super(USER_METHODS[:info], 'USER')
            require 'sqlite3'
            db = SQLite3::Database.new( "ganeti.db" )
            rows = db.execute( "select * from users where user_name = '" + username +"'" )           
            {:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}        
        end

        alias_method :info!, :info

      
        #######################################################################
        # Helpers to get User information
        #######################################################################

        # Returns the group identifier
        # [return] _Integer_ the element's group ID
        def gid
            self['GID'].to_i
        end

        # Returns a list with all the group IDs for the user including primary
        # [return] _Array_ with the group ID's (as integers)
        def groups
            all_groups = self.retrieve_elements("GROUPS/ID")           
            all_groups.collect! {|x| x.to_i}
        end
    end
end

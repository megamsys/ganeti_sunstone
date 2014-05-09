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
      @path = "/2/info"
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
      rows = db.execute( "select * from users where user_name = '" + username + "'" )
      {:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      zone = JSON.parse(@cc.data[:body])
      json = {"USER_POOL"=>
        {"USER"=>[{
              "ID"=>"0",
              "GID"=>"0",
              "GROUPS"=>{
                "ID"=>"0"
              },
              "GNAME"=>"oneadmin",
              "NAME"=>"oneadmin",
              "PASSWORD"=>"f1e91974588eb5a6f87711a1b44ee6d8f3c17522",
              "AUTH_DRIVER"=>"core",
              "ENABLED"=>"1",
              "TEMPLATE"=>{
                "TOKEN_PASSWORD"=>"7e53060a659d012590de42f7da5e876aa2ce494e"
              }
            },
            {
              "ID"=>"1",
              "GID"=>"0",
              "GROUPS"=>{
                "ID"=>"0"
              },
              "GNAME"=>"oneadmin",
              "NAME"=>"serveradmin",
              "PASSWORD"=>"5de917cec0a74af26586d6000333a1a687549961",
              "AUTH_DRIVER"=>"server_cipher",
              "ENABLED"=>"1",
              "TEMPLATE"=>{
                "TOKEN_PASSWORD"=>"2e988e09bec46687f02e6a180d916e2f040800ac"
              }
            },
            {
              "ID"=>"2",
              "GID"=>"100",
              "GROUPS"=>{
                "ID"=>"100"
              },
              "GNAME"=>"customer1",
              "NAME"=>"customer1-admin",
              "PASSWORD"=>"0eec62da57c9b6bbbbfec12d712aebeef1fbbbd5",
              "AUTH_DRIVER"=>"core",
              "ENABLED"=>"1",
              "TEMPLATE"=>{
                "TOKEN_PASSWORD"=>"9ba8d2c485196967b3ded31e34a427012ef8be5a"
              }
            }
          ],
          "QUOTAS"=>[{
              "ID"=>"0",
              "DATASTORE_QUOTA"=>{},
              "NETWORK_QUOTA"=>{},
              "VM_QUOTA"=>{},
              "IMAGE_QUOTA"=>{}},{
              "ID"=>"1",
              "DATASTORE_QUOTA"=>{},
              "NETWORK_QUOTA"=>{},
              "VM_QUOTA"=>{},
              "IMAGE_QUOTA"=>{}},{
              "ID"=>"2",
              "DATASTORE_QUOTA"=>{},
              "NETWORK_QUOTA"=>{},
              "VM_QUOTA"=>{},
              "IMAGE_QUOTA"=>{}}],
          "DEFAULT_USER_QUOTAS"=>{
            "DATASTORE_QUOTA"=>{},
            "NETWORK_QUOTA"=>{},
            "VM_QUOTA"=>{},
            "IMAGE_QUOTA"=>{}
          }}}
      json.to_json
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

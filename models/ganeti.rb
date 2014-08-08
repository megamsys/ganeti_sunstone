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


begin # require 'rubygems'
    require 'rubygems'
rescue Exception
end

require 'digest/sha1'
require 'rexml/document'
require 'pp'
require 'ganeti/client'
require 'ganeti/error'
require 'ganeti/user'
require 'ganeti/hosts'
require 'ganeti/clusters'
require 'ganeti/tenants'
require 'ganeti/virtual_machines'
require 'ganeti/virtual_networks'
require 'ganeti/images'
require 'ganeti/templates'
require 'ganeti/zones'
require 'ganeti/host_groups'

module Ganeti

    # OpenNebula version
    VERSION = '4.5.85'
end

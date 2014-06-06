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
require 'json'

module Ganeti
  class Zones
    def initialize(client)
      @path = "/2/info"
      @client = client
    end

    # Retrieves the information of the given User.
    def call
      @cc = @client.call(@path, 'GET')
      @cc
    #{:ID => rows[0][0], :NAME => rows[0][1], :GID => rows[0][4], :GNAME => rows[0][5]}
    end

    def to_json
      zone = JSON.parse(@cc.data[:body])
      json = {
        "ZONE_POOL" => build_json(0, zone["name"])
      }
      json.to_json
    end

    def info(param=nil)
      @cli = @client.call(@path, 'GET')
      @cli
    end

    def info_json
      zone = JSON.parse(@cli.data[:body])
      json = build_json(0, zone["name"])     
      json.to_json
    end

    def build_json(id, name)
      #ins_data = @client.call(@path+"/#{name}", 'GET')
      #inst_data = JSON.parse(ins_data.data[:body])
      endpoint = ENV['KEYSTONE_ENDPOINT_WITHOUT_PORT']
      b_json = {
        "ZONE" => {
          "ID" => id,
          "NAME" => name,
          "TEMPLATE" => {
            "ENDPOINT" => "#{endpoint}:5080"
          }
        }
      }
      b_json
    end

  end
end 
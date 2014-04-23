#!/usr/bin/env rake

# Rakefile
#require "./sunstone-server"
#require "./models/db"
require "sinatra/activerecord/rake"


 task :environment do
  require 'active_record'
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3'
 end

 desc "Migrate the database"
 task :migrate do
   require 'active_record'
  #ActiveRecord::Base.establish_connection :adapter => 'sqlite3'
  #ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Migration.verbose = true
  ActiveRecord::Migrator.migrate('db/migrate')
 end


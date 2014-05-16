#!/usr/bin/env rake

require 'sqlite3'

task :default do
@db = SQLite3::Database.new("ganeti.db")
@db.execute("PRAGMA foreign_keys = ON;")
puts "Database Initiated!"
end

task :clean => :default do
tables = ['users', 'templates']
tables.each {|table| @db.execute("drop table #{table};") }
puts "Tables are cleaned"
end

task :migrate => :clean do
@db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name varchar(256) UNIQUE DEFAULT NULL, password text, enabled int(11) DEFAULT NULL, gid integer, gname text);")  
puts "Users table is created"
@db.execute("CREATE TABLE templates(id INTEGER PRIMARY KEY AUTOINCREMENT, uid integer, name varchar(256), memory text, disk_size text, cpu text, os text, host_name text, created_at text, FOREIGN KEY(uid) REFERENCES users(id));")  
puts "Templates table is created"
@db.execute("INSERT INTO USERS(user_name, password, enabled, gid, gname) values('oneadmin', 'team4megam', 1, 0, 'oneadmin');")
puts "Default user inserted...."
end

task :init => :migrate do  
puts "Your Database ready to use !."  
end
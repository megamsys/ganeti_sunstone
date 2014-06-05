#!/usr/bin/env rake

require 'sqlite3'

task :default do
@db = SQLite3::Database.new("ganeti.db")
@db.execute("PRAGMA foreign_keys = ON;")
puts "Database Initiated!"
end

task :clean => :default do
tables = ['vms', 'templates', 'users']
tables.each {|table| @db.execute("drop table #{table};") }
puts "Tables are cleaned"
end

task :migrate => :clean do
@db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name varchar(256) UNIQUE DEFAULT NULL, password text, enabled int(11) DEFAULT NULL, gid integer, gname text);")  
puts "Users table is created"
@db.execute("CREATE TABLE templates(id INTEGER PRIMARY KEY AUTOINCREMENT, uid integer, name varchar(256), memory text, disk_size text, cpu text, os text, host_name text, machine text, kernel_path text, initrd text, kernel_args text, network_name text, sshkey text, created_at text, updated_at text, FOREIGN KEY(uid) REFERENCES users(id));")  
puts "Templates table is created"
@db.execute("INSERT INTO USERS(user_name, password, enabled, gid, gname) values('oneadmin', 'team4megam', 1, 0, 'oneadmin');")
puts "Default user inserted...."
@db.execute("CREATE TABLE vms (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name varchar(256), user_id text, tenant_name text, tenant_id text, vm_name text, host text, template_id integer, result text, job_id text);")
puts "Virtual Machine table created"
end

task :init => :migrate do  
puts "Your Database ready to use !."  
end

task :create => :default do
@db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name varchar(256) UNIQUE DEFAULT NULL, password text, enabled int(11) DEFAULT NULL, gid integer, gname text);")  
puts "Users table is created"
@db.execute("CREATE TABLE templates(id INTEGER PRIMARY KEY AUTOINCREMENT, uid integer, name varchar(256), memory text, disk_size text, cpu text, os text, host_name text, machine text, kernel_path text, initrd text, kernel_args text, network_name text, sshkey text, created_at text, updated_at text, FOREIGN KEY(uid) REFERENCES users(id));")  
puts "Templates table is created"
@db.execute("INSERT INTO USERS(user_name, password, enabled, gid, gname) values('oneadmin', 'team4megam', 1, 0, 'oneadmin');")
puts "Default user inserted...."
@db.execute("CREATE TABLE vms (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name varchar(256), user_id text, tenant_name text, tenant_id text, vm_name text, host text, template_id integer, os text, result text, job_id);")
puts "Virtual Machine table created"
end


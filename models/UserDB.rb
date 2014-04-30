##############################################################################
# Sqlite3
##############################################################################
#require "sinatra"
#require "sinatra/activerecord"

#set :database, "sqlite3:ganeti.db"

module UserDB
  def getUser(username)
    require 'sqlite3'
    db = SQLite3::Database.new( "ganeti.db" )
    rows = db.execute( "select * from users where user_name = '" + username +"'" )
    rows
  end
end
activerecord-jdbcsqlanywhere-adapter
===========================

This is an ActiveRecord JDBC adapter for Sybase SQLAnywhere.

## Standalone usage example:

    require 'rubygems'
    require 'active_record'
    CONFIG = {
      :username => 'user',
      :password => 'mypass',
      :adapter => 'sqlanywhere',
      :host => 'myhost',
      :database => 'mydb',
      :port => 9999
    }
    ActiveRecord::Base.establish_connection( CONFIG )
    sql = %{select count(*) from some_table}
    puts ActiveRecord::Base.connection.execute(sql)

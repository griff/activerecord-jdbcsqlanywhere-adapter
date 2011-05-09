config = { 
  :username => 'dba',
  :password => 'weblog',
  :adapter  => 'sqlanywhere',
  :host     => ENV[ "SQLANYWHERE_HOST" ] || 'localhost',
  :database => ENV[ "SQLANYWHERE_NAMESPACE" ] || 'weblog_development'
}

ActiveRecord::Base.establish_connection( config )

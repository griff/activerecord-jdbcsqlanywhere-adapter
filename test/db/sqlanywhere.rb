config = { 
  :username => 'dba',
  :password => 'sql',
  :adapter  => 'sqlanywhere',
  :host     => ENV[ "SQLANYWHERE_HOST" ] || 'localhost',
  :port     => ENV[ "SQLANYWHERE_PORT" ] || nil,
  :database => ENV[ "SQLANYWHERE_NAMESPACE" ] || 'ARTest'
}

ActiveRecord::Base.establish_connection( config )

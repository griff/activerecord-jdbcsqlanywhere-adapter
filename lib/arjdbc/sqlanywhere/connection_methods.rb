class ActiveRecord::Base
  class << self
    def sqlanywhere_connection( config )
      config[:port] ||= 2638
      config[:url] ||= "jdbc:sybase:Tds:#{config[:server]}:#{config[:port]}?serviceName=#{config[:database]}"
      config[:driver] ||= "com.sybase.jdbc3.jdbc.SybDriver"
      config[:dialect] = "sqlanywhere"
      jdbc_connection(config)
    end
  end
end
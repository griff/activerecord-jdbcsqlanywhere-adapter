class ActiveRecord::Base
  class << self
    def sqlanywhere_connection( config )
      version4 = true
      begin
        Java::com.sybase.jdbc4.jdbc.SybDriver
      rescue NameError
        version4 = false
      end
      config[:port] ||= 2638
      config[:url] ||= "jdbc:sybase:Tds:#{config[:host]}:#{config[:port]}?serviceName=#{config[:database]}"
      config[:driver] ||= version4 ? "com.sybase.jdbc4.jdbc.SybDriver" : "com.sybase.jdbc3.jdbc.SybDriver"
      config[:dialect] = "sqlanywhere"
      jdbc_connection(config)
    end
  end
end
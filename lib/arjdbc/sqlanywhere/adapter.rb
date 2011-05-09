module ::ArJdbc
  module SybaseSQLAnywhere
    def self.jdbc_connection_class
      ::ActiveRecord::ConnectionAdapters::SQLAnywhereJdbcConnection
    end
  end
end
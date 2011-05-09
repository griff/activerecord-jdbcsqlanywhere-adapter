module ::ArJdbc
  module SybaseSQLAnywhere
    def self.jdbc_connection_class
      ::ActiveRecord::ConnectionAdapters::SQLAnywhereJdbcConnection
    end
    
    def self.column_selector
      [/sqlanywhere/i, lambda {|cfg,col| col.extend(::ArJdbc::SybaseSQLAnywhere::Column)}]
    end
    
    module Column
      def init_column(name, default, *args)
        @name = name.downcase
      end
    end
  end
end
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

      # Post process default value from JDBC into a Rails-friendly format (columns{-internal})
      def default_value(value)
        # jdbc returns column default strings with actual single quotes around the value.
        return $1 if value =~ /^'(.*)'$/

        value
      end

      def simplified_type(field_type)
        case field_type
        when /int|bigint|smallint|tinyint/i                        then :integer
        when /numeric/i                                            then (@scale.nil? || @scale == 0) ? :integer : :decimal
        when /float|double|decimal|money|real|smallmoney/i         then :decimal
        when /datetime|smalldatetime/i                             then :datetime
        when /timestamp/i                                          then :timestamp
        when /time/i                                               then :time
        when /date/i                                               then :date
        when /text|ntext|xml/i                                     then :text
        when /binary|image|varbinary/i                             then :binary
        when /char|nchar|nvarchar|string|varchar/i                 then (@limit == 1073741823 ? (@limit = nil; :text) : :string)
        when /bit/i                                                then :boolean
        when /uniqueidentifier/i                                   then :string
        end
      end

      def type_cast(value)
        return nil if value.nil? || value == "(null)" || value == "(NULL)"
        case type
        when :primary_key then value == true || value == false ? value == true ? 1 : 0 : value.to_i
        when :boolean   then value == true or (value =~ /^t(rue)?$/i) == 0 or value=="1"
        else
          super
        end
      end
    end

    def quote_column_name(name)
      "\"#{name}\""
    end

    def quoted_true
      quote(1)
    end

    def quoted_false
      quote(0)
    end
    
    def sybaseserver_version
      @sybaseserver_version ||= select_value("select @@version").split('.').map(&:to_i)
    end

    def last_insert_id
      Integer(select_value("SELECT @@IDENTITY"))
    end

    def _execute(sql, name = nil)
      result = super
      ActiveRecord::ConnectionAdapters::JdbcConnection::insert?(sql) ? last_insert_id : result
    end
    
    def modify_types(tp) #:nodoc:
      tp[:primary_key] = "NUMERIC(22,0) DEFAULT AUTOINCREMENT PRIMARY KEY"
      tp[:integer][:limit] = nil
      tp[:boolean] = {:name => "bit"}
      tp[:binary] = {:name => "image"}
      tp
    end

    def type_to_sql(type, limit = nil, precision = nil, scale = nil) #:nodoc:
      limit = nil if %w(text binary).include? type.to_s
      return 'uniqueidentifier' if (type.to_s == 'uniqueidentifier')
      return super unless type.to_s == 'integer'

      if limit.nil? || limit == 4
        'int'
      elsif limit == 2
        'smallint'
      elsif limit == 1
        'tinyint'
      else
        'bigint'
      end
    end

    def add_limit_offset!(sql, options)
      if options[:limit] and options[:offset] and options[:offset] > 0
        sql.sub!(/^\s*SELECT(\s+DISTINCT)?/i,  "SELECT\\1 TOP #{options[:limit]} START AT #{options[:offset]+1}")
      elsif sql !~ /^\s*SELECT (@@|COUNT\()/i
        sql.sub!(/^\s*SELECT(\s+DISTINCT)?/i) do
          "SELECT#{$1} TOP #{options[:limit]}"
        end unless options[:limit].nil?
      end
    end
        
    def add_column_options!(sql, options) #:nodoc:
      super
      if options[:null] != false
        sql << " NULL"
      end
    end

    # Adds a new column to the named table.
    # See TableDefinition#column for details of the options you can use.
    def add_column(table_name, column_name, type, options = {})
      add_column_sql = "ALTER TABLE #{table_name} ADD #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
      fix_null = false
      if options[:null] == false
        fix_null = true
        options.delete(:null)
      end
      add_column_options!(add_column_sql, options)
      # TODO: Add support to mimic date columns, using constraints to mark them as such in the database
      # add_column_sql << " CONSTRAINT ck__#{table_name}__#{column_name}__date_only CHECK ( CONVERT(CHAR(12), #{quote_column_name(column_name)}, 14)='00:00:00:000' )" if type == :date
      execute(add_column_sql)
      execute("ALTER TABLE #{table_name} MODIFY #{quote_column_name(column_name)} NOT NULL") if fix_null
    end
    
    def remove_column(table_name, column_name)
      remove_from_primary_key(table_name, column_name)
      remove_from_index(table_name, column_name)
      remove_check_constraints(table_name, column_name)
      execute "ALTER TABLE #{table_name} DROP #{quote_column_name(column_name)}"
    end

    def remove_from_index(table_name, column_name)
    end

    def remove_check_constraints(table_name, column_name)
    end
    
    def remove_from_primary_key(table_name, column_name)
      columns = select "select col.cname from SYS.syscolumns col WHERE col.tname = '#{table_name}' AND in_primary_key = 'Y'"
      the_column, columns = columns.partition{|c| c['cname'].casecmp(column_name.to_s) == 0 }
      if the_column.size > 0
        execute "ALTER TABLE #{table_name} DROP PRIMARY KEY"
        if columns.size > 0
          columns.map! {|c| quote_column_name(c['cname'])}
          execute "ALTER TABLE #{table_name} ADD PRIMARY KEY (#{columns.join(', ')})"
        end
      end
    end

    def remove_index(table_name, options = {})
      execute "DROP INDEX #{table_name}.#{index_name(table_name, options)}"
    end
  end
end
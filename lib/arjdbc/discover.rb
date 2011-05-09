module ::ArJdbc
  extension :SybaseSQLAnywhere do |name|
    if name =~ /sqlanywhere/i
      require 'arjdbc/sqlanywhere'
      true
    end
  end
end
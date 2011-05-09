/*
 **** BEGIN LICENSE BLOCK *****
 * Copyright (c) 2006-2010 Nick Sieger <nick@nicksieger.com>
 * Copyright (c) 2006-2007 Ola Bini <ola.bini@gmail.com>
 * Copyright (c) 2008-2009 Thomas E Enebo <enebo@acm.org>
 * Copyright (c) 2011 Brian Olsen <brian@maven-group.org>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***** END LICENSE BLOCK *****/

package arjdbc.sqlanywhere;

import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

import arjdbc.jdbc.RubyJdbcConnection;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

/**
 *
 * @author brianolsen
 */
public class SQLAnywhereRubyJdbcConnection extends RubyJdbcConnection {
    protected SQLAnywhereRubyJdbcConnection(Ruby runtime, RubyClass metaClass) {
        super(runtime, metaClass);
    }

    public static RubyClass createSQLAnywhereJdbcConnectionClass(Ruby runtime, RubyClass jdbcConnection) {
        RubyClass clazz = RubyJdbcConnection.getConnectionAdapters(runtime).defineClassUnder("SQLAnywhereJdbcConnection",
                jdbcConnection, SQLANYWHERE_JDBCCONNECTION_ALLOCATOR);
        clazz.defineAnnotatedMethods(SQLAnywhereRubyJdbcConnection.class);

        return clazz;
    }

    private static ObjectAllocator SQLANYWHERE_JDBCCONNECTION_ALLOCATOR = new ObjectAllocator() {
        public IRubyObject allocate(Ruby runtime, RubyClass klass) {
            return new SQLAnywhereRubyJdbcConnection(runtime, klass);
        }
    };

    /**
     * Treat LONGVARCHAR as CLOB on Informix for purposes of converting a JDBC value to Ruby.
     */
    @Override
    protected IRubyObject jdbcToRuby(Ruby runtime, int column, int type, ResultSet resultSet)
            throws SQLException {
        if (type == Types.LONGVARCHAR) {
            type = Types.CLOB;
        }
        return super.jdbcToRuby(runtime, column, type, resultSet);
    }
    
    @Override
    protected IRubyObject unmarshalResults(ThreadContext context, DatabaseMetaData metadata,
                                           Statement stmt, boolean downCase) throws SQLException {
        return super.unmarshalResults(context, metadata, stmt, true);
    }
    
}

# Copyright 2008-2011 Red Hat, Inc, and individual contributors.
# 
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
# 
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'arjdbc'

module TorqueBox
  module Transactions
    module ActiveRecordAdapters

      module Connection

        def transaction(*)
          begin
            super
          rescue ActiveRecord::JDBCError => e
            unless self.is_a?(XAResource)
              puts "Creating an XAResource; exception=#{e}"
              self.extend(XAResource)
              retry
            else
              raise
            end
          end
        end

      end

      module XAResource

        # An XA connection is not allowed to begin/commit/rollback
        def begin_db_transaction
        end
        def commit_db_transaction
        end
        def rollback_db_transaction
        end

        # Defer execution of these tx-related callbacks invoked by
        # DatabaseStatements.transaction() until after the XA tx is
        # either committed or rolled back. 
        def commit_transaction_records(*)
          super if Manager.current.should_commit?(self)
        end
        def rollback_transaction_records(*)
          super if Manager.current.should_rollback?(self)
        end

      end

      module Transaction
        
        def prepare
          # TODO: not this, but we need AR's pooled connection to
          # refresh from jboss *after* the transaction is begun.
          ActiveRecord::Base.clear_active_connections!
          super
        end

        def error( exception )
          super
          raise exception unless exception.is_a?(ActiveRecord::Rollback)
        end

        def commit
          raise ActiveRecord::Rollback if @rolled_back
          super
          @complete = true
          connections.each { |connection| connection.commit_transaction_records }
        end

        def rollback
          super
          @complete = true
          connections.each { |connection| connection.rollback_transaction_records(:all) }
        end

        def should_commit?(connection)
          return true if @complete
          connections << connection
          false
        end

        def should_rollback?(connection)
          return true if @complete
          connections << connection
          @rolled_back = true
          false
        end
        
        def connections
          @connections ||= []
        end
      end
      
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class JdbcAdapter 
      include TorqueBox::Transactions::ActiveRecordAdapters::Connection
    end
  end
end
  
module TorqueBox
  module Transactions
    class Manager
      include TorqueBox::Transactions::ActiveRecordAdapters::Transaction
    end
  end
end


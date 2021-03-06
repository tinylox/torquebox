# Copyright 2008-2012 Red Hat, Inc, and individual contributors.
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

require 'java'
require 'torquebox/messaging/connection'

module TorqueBox
  module Messaging
    class ConnectionFactory

      attr_reader :internal_connection_factory
      
      def self.new(internal_connection_factory = nil)
        return internal_connection_factory if internal_connection_factory.is_a?( ConnectionFactory )
        super
      end

      def initialize(internal_connection_factory = nil)
        @internal_connection_factory = internal_connection_factory
      end

      def with_new_connection(options, &block)
        client_id = options[:client_id]
        connection = create_connection( options[:naming_host], options[:naming_port] )
        connection.client_id = client_id if client_id
        connection.start
        begin
          result = block.call( connection )
        ensure
          connection.close
        end
        return result
      end

      def create_connection(host, port)
        host ||= "localhost"
        port ||= 5445
        if !@internal_connection_factory
          # try to connect to HornetQ directly
          connect_opts = { "host" => host, "port" => port }
          transport_config =
            org.hornetq.api.core.TransportConfiguration.new("org.hornetq.core.remoting.impl.netty.NettyConnectorFactory", 
                                                            connect_opts)
          @internal_connection_factory =
            org.hornetq.api.jms.HornetQJMSClient.createConnectionFactoryWithoutHA( org.hornetq.api.jms::JMSFactoryType::CF, transport_config )
        end

        Connection.new( @internal_connection_factory.create_connection )
      end


      def to_s
        "[ConnectionFactory: internal_connection_factory=#{internal_connection_factory}]"
      end

    end
  end
end

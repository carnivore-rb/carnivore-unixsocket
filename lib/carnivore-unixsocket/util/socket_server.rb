require 'socket'
require 'carnivore-unixsocket'

module Carnivore
  module UnixSocket
    module Util
      class Server

        include Zoidberg::SoftShell
        include Zoidberg::Supervise
        include Carnivore::Utils::Logging

        # @return [String] socket path
        attr_reader :path
        # @return [UNIXServer]
        attr_reader :server
        # @return [Source]
        attr_reader :source
        # @return [IO]
        attr_reader :waker
        # @return [Array<IO>]
        attr_reader :connections

        # Create a new server
        #
        # @param args [Hash]
        # @option args [String] :path socket path
        # @return [self]
        def initialize(args={})
          @path = ::File.expand_path(args[:path])
          @source = args[:source]
          @connections = []
          @waker = IO.pipe.last
        end

        # Add a new connection
        #
        # @param con [UNIXSocket]
        # @return [NilClass]
        def add_connection(con)
          @connections.push(con)
          waker.write '-'
          nil
        end

        # Remove a connection
        #
        # @param con [UNIXSocket]
        # @return [NilClass]
        def remove_connection(con)
          @connections.delete(con)
          waker.write '-'
          nil
        end

        # Start the server listener loop
        def start_server!
          setup_server!
          loop do
            debug 'Waiting for new connection to socket'
            connection = server.accept
            debug 'Received new connection to socket, loading in...'
            add_connection(connection)
          end
        end

        # Start the message collector loop
        def start_collector!
          loop do
            IO.select(current_self.connections + [waker]).flatten.compact.each do |sock|
              if(sock == waker)
                sock.read
              else
                line = sock.gets
                if(line)
                  source.signal(:message, line.strip)
                else
                  sock.close
                end
              end
            end
          end
        end

        # Setup the path for the server and create new server
        #
        # @return [UNIXServer]
        def setup_server!
          unless(@server)
            if(::File.exists?(path))
              ::File.delete(path)
            end
            @server = UNIXServer.new(path)
          end
        end

      end
    end
  end
end

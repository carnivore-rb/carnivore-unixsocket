require 'carnivore-unixsocket'

module Carnivore
  class Source
    # Unix socket based carnivore source
    class UnixSocket < Source

      option :cache_signals

      # @return [String] path to socket
      attr_reader :socket
      # @return [String]
      attr_reader :srv_name
      # @return [Hash]
      attr_reader :init_args

      # Setup the unix socket
      #
      # @param args [Hash]
      def setup(args={})
        @write_lock = Mutex.new
        @socket = ::File.expand_path(args[:path])
        @srv_name = "socket_srv_#{name}".to_sym
        @connection = nil
        @init_args = args
      end

      # @return [Util::Server]
      def server
        @server
      end

      # @return [Celluloid::IO::UNIXSocket]
      def connection
        unless(@connection)
          @connection = UNIXSocket.new(socket)
        end
        @connection
      end

      # Initialize the server
      def init_srv
        @server = Carnivore::UnixSocket::Util::Server.new(
          :path => socket,
          :source => current_self
        )
        @server.async.start_collector!
        @server.async.start_server!
      end

      # Receive messages
      def receive(*args)
        line = wait(:message)
        begin
          MultiJson.load(line)
        rescue MultiJson::ParseError
          line
        end
      end

      # Send message
      #
      # @param payload [Object]
      # @param original_message [Carnivore::Message]
      def transmit(payload, original_message=nil)
        output = payload.is_a?(String) ? payload : MultiJson.dump(payload)
        @write_lock.synchronize do
          defer do
            connection.puts(output)
            connection.flush
          end
        end
      end

      # Override processing to enable server only if required
      def process(*args)
        init_srv
        super
      end

    end
  end
end

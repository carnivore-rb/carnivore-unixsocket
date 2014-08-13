require 'carnivore-unixsocket'

module Carnivore
  class Source
    # Unix socket based carnivore source
    class UnixSocket < Source

      # max time for unix socket to setup
      INIT_SRV_TIMEOUT = 2.0

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
        @socket = ::File.expand_path(args[:path])
        @srv_name = "socket_srv_#{name}".to_sym
        @connection = nil
        @init_args = args
      end

      # @return [Util::Server]
      def server
        callback_supervisor[srv_name]
      end

      # @return [Celluloid::IO::UNIXSocket]
      def connection
        unless(@connection)
          @connection = Celluloid::IO::UNIXSocket.new(socket)
        end
        @connection
      end

      # Initialize the server
      def init_srv
        callback_supervisor.supervise_as(srv_name,
          Carnivore::UnixSocket::Util::Server,
          init_args.merge(:notify_actor => current_actor)
        )
        waited = 0.0
        until(server || waited > INIT_SRV_TIMEOUT)
          sleep(0.01)
          waited += 0.01
        end
        server.async.start
      end

      # Receive messages
      def receive(*args)
        wait(:new_socket_lines)
        server.return_lines.map do |line|
          puts "LOADING LINE: #{line.inspect}"
          begin
            MultiJson.load(line)
          rescue MultiJson::ParseError
            line
          end
        end
      end

      # Send message
      #
      # @param payload [Object]
      # @param original_message [Carnivore::Message]
      def transmit(payload, original_message=nil)
        output = payload.is_a?(String) ? payload : MultiJson.dump(payload)
        connection.puts(output)
        connection.flush
      end

      # Override processing to enable server only if required
      def process(*args)
        init_srv
        super
      end

    end
  end
end

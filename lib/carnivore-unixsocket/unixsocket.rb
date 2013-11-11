require 'carnivore'
require 'carnivore-unixsocket/util/socket_server'

module Carnivore
  class Source
    class UnixSocket < Source

      attr_reader :socket, :srv_name, :init_args

      def setup(args={})
        @socket = ::File.expand_path(args[:path])
        @srv_name = "socket_srv_#{name}".to_sym
        @connection = nil
        @init_args = args
      end

      def server
        Celluloid::Actor[srv_name]
      end

      def connection
        unless(@connection)
          @connection = Celluloid::IO::UnixSocket.new(socket)
        end
        @connection
      end

      def init_srv
        callback_supervisor.supervise_as(srv_name,
          Carnivore::UnixSocket::Util::Server,
          init_args.merge(:notify_actor => current_actor)
        )
        server.async.start
      end

      def receive(*args)
        wait(:new_socket_lines)
        server.return_lines
      end

      def transmit(payload, original_message)
        connection.write_line(payload)
      end

      def process(*args)
        init_srv
        super
      end

    end
  end
end

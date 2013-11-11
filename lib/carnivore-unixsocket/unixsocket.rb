require 'carnivore'
require 'socket'
require 'carnivore-unixsocket/util/socket_fetcher'

module Carnivore
  class Source
    class UnixSocket < Source

      attr_reader :socket, :fetcher_name

      def setup(args={})
        @socket = File.expand_path(args[:file])
        @fetcher_name = "socket_fetcher_#{name}".to_sym
        callback_supervisor.supervise_as(fetcher_name, Carnivore::UnixSocket::Util::Fetcher,
          args.merge(:notify_actor => current_actor)
        )
      end

      def fetcher
        Celluloid::Actor[fetcher_name]
      end

      def connect
        fetcher.async.start_fetcher
      end

      def receive(*args)
        wait(:new_socket_lines)
      end

      def transmit(payload, original_message)
        fetcher.write_line(payload)
      end

    end
  end
end

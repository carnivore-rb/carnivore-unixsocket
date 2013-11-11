require 'celluloid/io'
require 'carnivore-unixsocket/util/socket_connection'

module Carnivore
  module UnixSocket
    module Util
      class Server

        include Celluloid
        include Carnivore::Utils::Logging

        attr_reader :path, :notify_actor, :server, :supervisor

        def initialize(args={})
          @path = ::File.expand_path(args[:path])
          @notify_actor = args[:notify_actor]
          @supervisor = Celluloid::SupervisionGroup.run!
          @messages = []
        end

        def start
          srv_actor = current_actor
          defer do
            loop do
              setup_server!
              debug 'Waiting for new connection to server'
              connection = server.accept
              debug 'Received new connection to server. Setting up connection...'
              supervisor.supervise_as("con_#{connection.hash}", Connection,
                :io => connection, :server => srv_actor, :auto_consume => true
              )
              debug 'Connection setup complete and active'
            end
          end
        end

        def setup_server!
          unless(@server)
            if(::File.exists?(path))
              ::File.delete(path)
            end
            @server = Celluloid::IO::UNIXServer.new(path)
          end
        end

        def add_lines(lines)
          lines = [lines] unless lines.is_a?(Array)
          @messages += lines
          notify_actor.signal(:new_socket_lines)
        end

        def return_lines
          msgs = @messages.dup
          @messages.clear
          msgs
        end

      end
    end
  end
end

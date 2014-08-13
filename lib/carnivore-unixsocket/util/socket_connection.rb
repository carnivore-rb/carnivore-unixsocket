require 'carnivore-unixsocket'
require 'celluloid/io'

module Carnivore
  module UnixSocket
    module Util
      class Connection

        include Celluloid

        attr_reader :srv, :io

        def initialize(args={})
          @io = args[:io]
          @io.sync
          @srv = args[:server]
          async.consume! if args[:auto_consume]
        end

        def consume!
          defer do
            loop do
              line = receive
              unless(line.empty?)
                srv.add_lines([line])
              end
            end
          end
        end

        def send(s)
          io.puts s
          io.flush
        end

        def receive
          line = io.gets
          if(line)
            line.strip
          else
            io.close
            terminate
          end
        end

      end
    end
  end
end

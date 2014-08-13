require 'carnivore-unixsocket'

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

        def write_line(s)
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

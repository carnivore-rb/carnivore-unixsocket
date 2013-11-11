module Carnivore
  module File
    module Util
      class Fetcher

        include Celluloid
        include Carnivore::Utils::Logging

        attr_reader :path, :delimiter, :notify_actor
        attr_accessor :messages, :io

        def initialize(args={})
          @leftover = ''
          @path = ::File.expand_path(args[:file])
          @delimiter = args.fetch(:delimiter, "\n")
          @notify_actor = args[:notify_actor]
          @messages = []
        end

        def return_lines
          msgs = messages.dup
          messages.clear
          msgs
        end

        def write_line(line)
          if(io)
            io.puts(line)
          else
            raise 'No IO detected! Failed to write.'
          end
        end

        def retrieve_lines
          if(io)
            while(data = io.read(4096))
              @leftover << data
            end
            result = @leftover.split(delimiter)
            @leftover.replace @leftover.end_with?(delimiter) ? '' : result.pop.to_s
            result
          else
            []
          end
        end

      end
    end
  end
end

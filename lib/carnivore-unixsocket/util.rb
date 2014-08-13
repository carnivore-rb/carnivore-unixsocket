require 'carnivore-unixsocket'

module Carnivore
  module UnixSocket
    module Util

      autoload :Connection, 'carnivore-unixsocket/util/socket_connection'
      autoload :Server, 'carnivore-unixsocket/util/socket_server'

    end
  end
end

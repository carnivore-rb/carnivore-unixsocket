require 'celluloid/io'
require 'carnivore'

module Carnivore
  module UnixSocket

    autoload :Util, 'carnivore-unixsocket/util'

  end
end

require 'carnivore-unixsocket/version'
Carnivore::Source.provide(:unix_socket, 'carnivore-unixsocket/unixsocket')

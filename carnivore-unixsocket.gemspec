$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'carnivore-unixsocket/version'
Gem::Specification.new do |s|
  s.name = 'carnivore-unixsocket'
  s.version = Carnivore::UnixSocket::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'https://github.com/carnivore-rb/carnivore-unixsocket'
  s.description = 'Carnivore Unix Socket Source'
  s.require_path = 'lib'
  s.add_dependency 'carnivore', '>= 0.1.8'
  s.add_dependency 'celluloid-io'
  s.files = Dir['**/*']
end

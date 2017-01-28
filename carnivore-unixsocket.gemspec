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
  s.license = 'Apache 2.0'
  s.require_path = 'lib'
  s.add_dependency 'carnivore', '>= 1.0'
  s.files = Dir['lib/**/*'] + %w(carnivore-unixsocket.gemspec README.md CHANGELOG.md)
end

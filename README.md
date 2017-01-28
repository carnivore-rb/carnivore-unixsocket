# Carnivore Unix Socket

Provides Unix Socket `Carnivore::Source`

# Usage

```ruby
require 'carnivore'
require 'carnivore-unixsocket'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :unix_socket, :args => {:path => '/var/run/my.sock'}
  )
end
```

# Info
* Carnivore: https://github.com/carnivore-rb/carnivore
* Repository: https://github.com/carnivore-rb/carnivore-unixsocket
* IRC: Freenode @ #carnivore

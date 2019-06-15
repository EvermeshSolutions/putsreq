lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'putsreq/version'

Gem::Specification.new do |gem|
  gem.name          = 'putsreq'
  gem.version       = PutsReq::VERSION
  gem.authors       = ['Pablo Cantero']
  gem.email         = ['pablo@pablocantero.com']
  gem.description   = 'Ruby CLI for PutsReq'
  gem.summary       = 'Ruby CLI for PutsReq'
  gem.homepage      = 'https://github.com/phstc/putsreq'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = %w[putsreq]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'pusher-client', '~> 0.6.2'
  gem.add_dependency 'thor', '~> 0.19.3'
end

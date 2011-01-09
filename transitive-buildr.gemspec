unless defined?(TransitiveBuildr::VERSION)
  require File.join(File.dirname(__FILE__), 'lib', 'transitive-buildr', 'version')
end

Gem::Specification.new do |spec|
  spec.name           = 'transitive-buildr'
  spec.version        = TransitiveBuildr::VERSION.dup
  spec.author         = 'John Shahid'
  spec.email          = "jvshahid@gmail.com"
  spec.homepage       = "https://github.com/jvshahid/transitive-buildr"
  spec.summary        = "A Buildr extension that enables transitive dependency resolution by default"

  # Rakefile needs to create spec for both platforms (ruby and java), using the
  # $platform global variable.  In all other cases, we figure it out from RUBY_PLATFORM.
  spec.platform       = $platform || RUBY_PLATFORM[/java/] || 'ruby'

  spec.files                 = Dir['{lib,spec}/**/*', '*.{gemspec}']
  spec.require_paths  = ['lib']

  spec.has_rdoc         = false

  # Tested against these dependencies.
  spec.add_dependency 'rake',                 '0.8.7'
  spec.add_dependency 'buildr',              '>= 1.4.4'
  spec.add_dependency 'rspec',                '~> 1.3.1'
end

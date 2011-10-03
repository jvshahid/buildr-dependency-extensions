# -*- ruby -*-

unless defined?(BuildrDepenencyExtensions::VERSION)
  require File.join(File.dirname(__FILE__), 'lib', 'buildr-dependency-extensions', 'version')
end

Gem::Specification.new do |spec|
  spec.name           = 'buildr-dependency-extensions'
  spec.version        = BuildrDependencyExtensions::VERSION.dup
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
  spec.add_dependency 'buildr',               '>= 1.4.5'
  spec.add_dependency 'xml-simple',           '~> 1.0.12'
  spec.add_dependency 'rspec-expectations',   '2.1.0'
  spec.add_dependency 'rspec-mocks',          '2.1.0'
  spec.add_dependency 'rspec-core',           '2.1.0'
  spec.add_dependency 'rspec',                '2.1.0'
end

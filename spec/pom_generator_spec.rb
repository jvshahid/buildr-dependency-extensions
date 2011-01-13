require 'rubygems'
require 'buildr'
require 'lib/transitive-buildr'

include TransitiveBuildr

describe TransitiveBuildr::PomGenerator do
  it 'should add all compile dependencies with compile scope'
  it 'should add all runtime dependencies with runtime scope'
  it 'should add all test dependencies with test scope'
end

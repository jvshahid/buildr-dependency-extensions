require 'buildr/packaging/artifact.rb'

class Buildr::Artifact
  attr_accessor :depth

  def excludes(*artifacts)
    @excludes ||= []
    @excludes = @excludes + artifacts
    self
  end
end

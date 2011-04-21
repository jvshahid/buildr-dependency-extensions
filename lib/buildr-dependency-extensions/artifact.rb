require 'buildr/packaging/artifact.rb'

class Buildr::Artifact
  def excludes(*artifacts)
    @excludes ||= []
    @excludes = @excludes + artifacts
    self
  end
end

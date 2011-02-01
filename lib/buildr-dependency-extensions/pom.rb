require 'buildr/java/pom'

class Buildr::POM
  def declared_dependencies(scopes)
    #try to cache dependencies also
    @declared_depends_for_scopes ||= {}
    unless depends = @declared_depends_for_scopes[scopes]
      declared = project["dependencies"].first["dependency"] rescue nil
      depends = (declared || []).reject { |dep| value_of(dep["optional"]) =~ /true/ }
      depends = depends.map do |dep|
        spec = pom_to_hash(dep, properties)
        apply = managed(spec)
        spec = apply.merge(spec) if apply

        #calculate transitive dependencies
        if scopes.include?(spec[:scope])
          exclusions = dep["exclusions"]["exclusion"] rescue nil
          artifact = Artifact.to_spec(spec)

          if exclusions
            excuded_artifacts = exclusions.map {|exclusion| artifact("#{exclusion['groupId']}:#{exclusion['artifactId']}:jar:1.0")}
            artifact.excludes(*excuded_artifacts)
          end
        end
        artifact
      end
      depends = depends.compact
      @declared_depends_for_scopes[scopes] = depends
    end
    depends
  end
end

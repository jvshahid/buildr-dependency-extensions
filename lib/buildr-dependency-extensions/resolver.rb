module BuildrDependencyExtensions
  class ResolverBase
    def initialize
      @hash = {}
    end

    def resolve_from_hash artifact
      @hash[artifact]
    end

    def resolved artifact, version
      # @hash[artifact] = version
    end
  end

  class HighestVersionConflictResolver < ResolverBase
    def resolve artifact, all_artifacts
      version = resolve_from_hash artifact
      if version
        version
      else
        all_versions = HelperFunctions.get_all_versions(artifact, all_artifacts).uniq
        if all_versions.size > 1
          puts $terminal.color("Warning: found versions #{all_versions.join(', ')} for artifact #{artifact}. Choosing #{all_versions[0]}", :yellow)
        end
        resolved artifact, all_versions[0]
        all_versions[0]
      end
    end
  end

  class MavenVersionConflictResolver < ResolverBase
    def resolve artifact, all_artifacts
      version = resolve_from_hash artifact
      if version
        version
      else
        all_versions = HelperFunctions.get_all_versions_sorted_by_depth(artifact, all_artifacts).uniq
        resolved artifact, all_versions[0]
        all_versions[0]
      end
    end
  end
end

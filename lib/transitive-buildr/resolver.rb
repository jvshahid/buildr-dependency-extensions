module TransitiveBuildr
    end
  end

  class HighestVersionConflictResolver
    def resolve artifact, all_versions
      all_versions = all_versions.sort.reverse.uniq
      puts "Selecting the highest version #{all_versions[0]} for artifact #{artifact}" if all_versions.size > 0
      all_versions[0]
    end
  end

  class DependencyLockFileConflictResolver
  end
end

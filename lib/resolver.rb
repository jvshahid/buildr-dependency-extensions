module DependencyLocking
  class InteractiveConflictResolver
    def resolve artifact, all_versions
      all_versions = all_versions.sort.reverse.uniq
      selected_version = nil
      if all_versions.size > 1 then
        begin
          puts "Please select the version of #{artifact} that you'd like to use"
          all_versions.each_index {|index| puts "#{index})\t#{all_versions[index]}"}
          selected_version_index = $stdin.gets.to_i
          selected_version = all_versions[selected_version_index] if selected_version_index < all_versions.size
        end while !selected_version
      else
        selected_version = all_versions[0]
      end
      selected_version
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

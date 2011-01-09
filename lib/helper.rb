require 'buildr/packaging/artifact'

module TransitiveBuildr

  class HelperFunctions
    # Change the version number to 0 and invoke uniq on the resulting array to get a unique set of artifacts (ignoring the version number)
    def HelperFunctions.get_unique_group_artifact set
      new_set = set.map { |artifact| hash = Artifact.to_hash(artifact); hash[:version] = 0; Artifact.to_spec(hash) }
      new_set.uniq
    end

    # returns all versions of artifact in original_set sorted using the Version sorting order
    def HelperFunctions.get_all_versions artifact, original_set
      original_artifact_hash = Artifact.to_hash(artifact)

      new_set = original_set.select do |candidate_artifact|
        candidate_hash = Artifact.to_hash(artifact)
        candidate_hash[:group] == original_artifact_hash[:group] &&
          candidate_hash[:id] == original_artifact_hash[:id]  &&
          candidate_hash[:type] == original_artifact_hash[:type] &&
          candidate_hash[:classifier] == original_artifact_hash[:classifier]
      end

      new_set.
        map { |artifact| Artifact.to_hash(artifact)[:version] }.
        map { |version_string| Version.new version_string}.uniq.sort.reverse
    end
  end

  # Parses the version string and provides a natural ordering for versions
  class Version
    include Comparable

    attr_reader :version_array, :version_string

    def initialize version_string
      @version_string = version_string
      @version_array = version_string.split('.')
    end

    def <=> other_version
      @version_array <=> other_version.version_array
    end

    alias_method :eql?, :==

    def hash
      @version_string.hash
    end

    def to_s
      @version_string
    end
  end
end

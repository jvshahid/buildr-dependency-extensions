require 'buildr/core/project'
require 'yaml'

module TransitiveBuildr

  include Extension

  after_define(:compile => :'transitive-buildr')
  after_define(:'transitive-buildr') do |project|
    # We have to run the pom generator first before we mess up the dependencies
    # A cleaner way is to store the old dependencies before we change them
    generate_pom project
    # Add the compile dependencies to the run task
    compile_dependencies = project.compile.dependencies.select {|dep| HelperFunctions.is_artifact? dep }
    runtime_dependencies = compile_dependencies + project.run.classpath
    runtime_file_tasks = runtime_dependencies.reject {|dep| HelperFunctions.is_artifact? dep }
    runtime_artifacts = runtime_dependencies - runtime_file_tasks
    transitive_runtime_artifacts = runtime_artifacts.inject([]) do |set, dependency|
      set + project.transitive(dependency)
    end
    unique_transitive_artifacts = HelperFunctions.get_unique_group_artifact(transitive_runtime_artifacts)
    version_conflict_resolver = HighestVersionConflictResolver.new
    new_runtime_artifacts = unique_transitive_artifacts.map do |artifact|
      all_versions = HelperFunctions.get_all_versions artifact, transitive_runtime_artifacts
      artifact_hash = Artifact.to_hash(artifact)
      artifact_hash[:version] = version_conflict_resolver.resolve artifact, all_versions
      project.artifact(Artifact.to_spec(artifact_hash))
    end
    project.run.classpath = new_runtime_artifacts + runtime_file_tasks

    # Add the test dependencies to the run task
    test_dependencies = compile_dependencies + project.test.classpath
    test_file_tasks = test_dependencies.reject {|dep| HelperFunctions.is_artifact? dep }
    test_artifacts = test_dependencies - test_file_tasks
    transitive_test_artifacts = test_artifacts.inject([]) do |set, dependency|
      set + project.transitive(dependency)
    end
    unique_transitive_artifacts = HelperFunctions.get_unique_group_artifact(transitive_test_artifacts)
    new_test_artifacts = unique_transitive_artifacts.map do |artifact|
      all_versions = HelperFunctions.get_all_versions artifact, transitive_test_artifacts
      artifact_hash = Artifact.to_hash(artifact)
      artifact_hash[:version] = version_conflict_resolver.resolve artifact, all_versions
      project.artifact(Artifact.to_spec(artifact_hash))
    end
    project.test.dependencies = new_test_artifacts + test_file_tasks
    project.test.compile.dependencies = project.test.dependencies
  end

  # Private methods
  private

  def compile_dependencies project
    project.compile.dependencies.select {|dep| HelperFunctions.is_artifact? dep}
  end

  def runtime_dependencies project
    project.run.classpath.select {|dep| HelperFunctions.is_artifact? dep}
  end

  def test_dependencies project
    project.test.dependencies.select {|dep| HelperFunctions.is_artifact? dep}
  end

  def generate_dependencies_string dependencies, scope
    dependencies.map do |dep|
      <<-DEP
    <dependency>
      <groupId>#{dep.to_hash[:group]}</groupId>
      <artifactId>#{dep.to_hash[:id]}</artifactId>
      <version>#{dep.to_hash[:version]}</version>
      <scope>#{scope}</scope>
      <type>#{dep.to_hash[:type]}</type>
    </dependency>
DEP
    end.join('\n')
  end

  def generate_pom project
    artifact_id = project.name
    group_id = project.group
    version = project.version

    pom_xml = <<-POM
<?xml version="1.0" encoding="UTF-8"?>
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>#{group_id}</groupId>
  <artifactId>#{artifact_id}</artifactId>
  <version>#{version}</version>

POM
    compile_dependencies =  compile_dependencies project
    runtime_dependencies =  runtime_dependencies project
    test_dependencies    =  test_dependencies project

    dependencies_string =  generate_dependencies_string compile_dependencies, "compile"
    dependencies_string += generate_dependencies_string runtime_dependencies, "runtime"
    dependencies_string += generate_dependencies_string test_dependencies, "test"

    pom_xml += "  <dependencies>\n#{dependencies_string}  </dependencies>\n" unless dependencies_string.empty?
    pom_xml += "</project>\n"

    my_pom = file(project.path_to(:target, 'pom.xml')) do |f|
      FileUtils.mkdir_p(File.dirname(f.name)) unless f.exist?
      File.open(f.name, 'w') do |file|
        file.write(pom_xml)
      end
    end

    project.package.pom.from my_pom
  end
end

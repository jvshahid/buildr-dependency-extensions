require 'buildr/core/project'

module BuildrDependencyExtensions
  module PomGenerator

    include Extension

    # We have to run the pom generator first before the dependencies are
    # changed in the compile, test and run after_define
    after_define(:compile => :'pom-generator')
    after_define(:'pom-generator') do |project|
      generate_pom project
    end

    module_function

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
      end.join("")
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
end

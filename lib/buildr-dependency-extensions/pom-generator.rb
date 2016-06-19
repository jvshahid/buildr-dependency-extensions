require 'buildr/core/project'
require 'rubygems'
require 'xmlsimple'

module BuildrDependencyExtensions
  module PomGenerator

    include Extension

    def self.extended(base)
      class << base
        def extra_pom_sections
          @extra_pom_sections ||= {}
        end
      end
      super
    end

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

    def generate_dependencies_hash dependencies, scope
      dependencies.map do |dep|
        { 'groupId'    => dep.to_hash[:group],
          'artifactId' => dep.to_hash[:id],
          'version'    => dep.to_hash[:version],
          'scope'      => scope,
          'type'       => dep.to_hash[:type]
        }
      end
    end

    def generate_pom project
      compile_dependencies =  compile_dependencies project
      runtime_dependencies =  runtime_dependencies project
      test_dependencies    =  test_dependencies    project

      dependencies_hashes  = generate_dependencies_hash compile_dependencies, 'compile'
      dependencies_hashes += generate_dependencies_hash runtime_dependencies, 'runtime'
      dependencies_hashes += generate_dependencies_hash test_dependencies,    'test'

      pom_hash = {
        'modelVersion' => '4.0.0',
        'groupId'      => project.group,
        'artifactId'   => project.name.gsub(":", "-"),
        'version'      => project.version,
        'dependencies' => {'dependency' => dependencies_hashes.to_a}
      }

      project.extra_pom_sections.each {|key, value| pom_hash[key] = value}

      my_pom = file(project.path_to(:target, 'pom.xml')) do |f|
        FileUtils.mkdir_p(File.dirname(f.name)) unless f.exist?
        File.open(f.name, 'w') do |file|
          file.write(XmlSimple.xml_out(pom_hash, {'RootName' => 'project', 'NoAttr' => true}))
        end
      end

      project.package.pom.from my_pom
    end
  end
end

# Introduction:
This is a Buildr extension that will convert Buildr to transitively resolve dependencies. Transitive dependencies are only enabled for runtime and test dependencies.

# Goals
1. Compile dependencies and runtime dependencies are added to runtime dependencies
2. Test dependencies, runtime dependencies and compile dependencies are added to test dependencies
3. Runtime and test dependencies are resolved transitively.
4. Resolving conflicts should be flexible. There's currently three ways to resolve conflicts:
    1. Using a dependency lock file
    2. Interactive conflict resolution (which will generate a lock file)
    3. Using the highest version (this is the only way to resolve conflicts right now)

# Usage
Following is an example of a buildfile that uses TransitiveBuildr
    require 'transitive-buildr/transitive-buildr'

    repositories.remote << "http://www.ibiblio.org/maven2/"

    define 'foo-bar' do
      extend TransitiveBuildr

      # define the project-version
      project.version = '1.0.0'

      compile.with artifact('mysql:mysql-connector-java:jar:5.1.14')
      compile.with artifact('org.clojure:clojure:jar:1.2.0')
      run.with artifact('mysql:mysql-connector-java:jar:5.1.13')
    end

In this example the runtime dependencies will be `mysql:mysql-connector-java:jar:5.1.14` and `org.clojure:clojure:jar:1.2.0`
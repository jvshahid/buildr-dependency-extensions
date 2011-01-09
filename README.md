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
See the [Usage wiki section](https://github.com/jvshahid/transitive-buildr/wiki/Usage) for examples.
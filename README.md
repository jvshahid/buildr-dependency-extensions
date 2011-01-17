# Introduction:
This is a Buildr extension that will convert Buildr to transitively resolve dependencies. I built it so I can easily move my projects from maven to buildr. Furthermore, there is a pom generator that can generate a complete pom including the project dependencies with the right scope. I found these tasks to be easy to carry by hand but tedious at the same time given that dependencies tend to change as the project evolve.

# Goals
1. Runtime dependencies are resolved transitively and added to the run task dependencies
2. Test dependencies are resolved transitively and added to the test task dependencies
3. No two versions of the same artifact should be present in the dependencies. To resolve conflicts:
    1. Use a dependencies version lock file
    2. Falling back to using the highest version if the lock file didn't specify a version for the given artifact.
4. Generate a project pom with dependencies that have the right dependencies.

# Usage
See the [Usage wiki section](https://github.com/jvshahid/buildr-dependency-extensions/wiki) for examples.
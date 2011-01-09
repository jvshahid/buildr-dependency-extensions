# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

# We need JAVA_HOME for most things (setup, spec, etc).

# Load the Gem specification for the current platform (Ruby or JRuby).
require 'spec/rake/spectask'

def default_spec_opts
  default = %w{--backtrace}
  default << '--colour' if $stdout.isatty
  default
end

desc "Run all specs"
Spec::Rake::SpecTask.new :spec do |task|
  task.spec_files = FileList['spec/**/*_spec.rb']
  task.spec_opts = default_spec_opts
  task.spec_opts << '--format specdoc'
end

# -*- ruby -*-

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

module Tags
  RUBY_FILES    = FileList['**/*.rb'].exclude("pkg")
  TAG_FILE      = "#{File.dirname(__FILE__)}/../TAGS"
end

namespace "emacs" do
  desc "Generate tags for emacs"
  task :tags => Tags::RUBY_FILES do
    puts "Making Emacs TAGS file"
    # ctags-exuberant is a better tool for generating ruby (and a bunch of other languages) tags
    which_tagging_tool = `which ctags-exuberant`[0..-2]

    if which_tagging_tool.empty?
      which_tagging_tool = `which etags`[0..-2]
    else
      which_tagging_tool << " --extra=+f -e"
    end

    raise 'Please install either etags or ctags-exuberant' if which_tagging_tool.empty?

    sh "#{which_tagging_tool} -o #{Tags::TAG_FILE} #{Tags::RUBY_FILES}", :verbose => false
  end
end

desc "Run emacs:tags"
task :tags => ["emacs:tags"]

#!/usr/bin/env bash

java=$(readlink -f $(which java))
export JAVA_HOME=${java%jre/*}
echo "Set JAVA_HOME to $JAVA_HOME"
bundle install
rake

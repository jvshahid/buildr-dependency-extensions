#!/usr/bin/env bash

java=$(which java)
export JAVA_HOME=${java%bin/*}
echo "Set JAVA_HOME to $JAVA_HOME"
bundle install
#!/usr/bin/env bash

java=$(which java)
export JAVA_HOME=${java%bin/*}

bundle install
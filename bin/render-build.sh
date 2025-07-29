#!/bin/bash
set -e

RUBY_VERSION=3.4.1

echo "Using Ruby version: $RUBY_VERSION"

gem update --system --no-document
gem install -N bundler

bundle install

echo "Build completed."

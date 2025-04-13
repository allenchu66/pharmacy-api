#!/bin/bash

# echo "Run Rubocop..."
# bundle exec rubocop || exit 1

echo "Run RSpec..."
bundle exec rspec || exit 1

echo "✅ Local CI check pass!"
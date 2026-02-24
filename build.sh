#!/bin/bash

set -e

if [ "$CF_PAGES_BRANCH" = "main" ]; then
  echo "Building for production..."
  hugo --minify
else
  echo "Building for preview..."
  hugo -b "$CF_PAGES_URL" --minify
fi
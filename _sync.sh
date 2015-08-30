#!/bin/bash
set -euo pipefail

jekyll build
rsync -Cavz --delete _site/ me-waleedkhan:home/281/

#!/bin/bash
set -e

# Merge all team JSON tfvars files into one combined JSON object under the "project" key.
jq -s 'reduce .[] as $item ({}; . * $item) | {projects: .}' teams/*/project.tfvars.json > combined_projects.tfvars.json

echo "Combined projects file created: combined_projects.tfvars.json"

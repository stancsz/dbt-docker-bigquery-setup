#!/bin/bash

# Define project name
PROJECT_NAME="dbt-docker-bigquery-setup"
DBT_PROFILES_DIR="$HOME/.dbt"

# Create project directory
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Create Dockerfile
cat <<EOF > Dockerfile
FROM fishtownanalytics/dbt:latest

WORKDIR /dbt

# Copy dbt project files
COPY . .

ENTRYPOINT ["dbt"]
EOF

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.7'

services:
  dbt:
    build: .
    volumes:
      - .:/dbt
    entrypoint: ["dbt"]
EOF

# Create profiles.yml in the .dbt directory
mkdir -p $DBT_PROFILES_DIR
cat <<EOF > $DBT_PROFILES_DIR/profiles.yml
my_dbt_project:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: your-gcp-project-id
      dataset: your_dataset
      threads: 1
      keyfile: /path/to/your/credentials.json
EOF

# Initialize dbt project
dbt init $PROJECT_NAME

# Create a dummy model file
mkdir -p models
cat <<EOF > models/example_model.sql
-- Example model
SELECT
  1 as example_column
EOF

echo "Setup complete. You can now use 'docker-compose run dbt compile' to render and dry run your dbt models."

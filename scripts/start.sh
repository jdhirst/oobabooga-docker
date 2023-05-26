#!/bin/bash

# Copy all data from characters.dist
cp -r /app/text-generation-webui/characters.dist/Example* /data/characters/
cp -r /app/text-generation-webui/characters.dist/instruction-following /data/characters/

# Start the server
/opt/conda/bin/conda run --no-capture-output -n textgen python server.py "$@"

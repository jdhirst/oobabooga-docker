#!/bin/bash

# Remove the models directory and create a symbolic link
rm -r /app/text-generation-webui/models
ln -s /models /app/text-generation-webui/models

# Start the server
conda run --no-capture-output -n textgen python server.py "$@"

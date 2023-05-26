# Start with a base image
FROM registry.access.redhat.com/ubi9:latest

# Update the base image
RUN dnf update -y

# Working directory
RUN mkdir /app
WORKDIR /app

# Install required packages
RUN dnf install -y git wget gcc gcc-c++ make 
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh;bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda

# Create a new environment
RUN /opt/conda/bin/conda create -y -n textgen python=3.10.9 

# Activate the environment and install PyTorch
SHELL ["/opt/conda/bin/conda", "run", "-n", "textgen", "/bin/bash", "-c"]
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Clone the repository
RUN git clone https://github.com/oobabooga/text-generation-webui

# Install the requirements
RUN cd text-generation-webui && pip install -r requirements.txt

# Set the working directory
WORKDIR /app/text-generation-webui

# Add a script that creates the symbolic link and starts the server
ADD scripts/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Define the entrypoint
ENTRYPOINT ["/app/start.sh"]

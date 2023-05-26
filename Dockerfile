# Start with a base image
FROM registry.access.redhat.com/ubi9:latest

# Update the base image
RUN dnf update -y

# Working directory
RUN mkdir /app
WORKDIR /app

# Install required packages
RUN dnf install -y git wget gcc gcc-c++ make

# Create a new environment
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    chown -R root:root /opt/conda

# Activate the environment and install PyTorch
SHELL ["/bin/bash", "-c"]
RUN /opt/conda/bin/conda create -y -n textgen python=3.10.9 && \
    /opt/conda/bin/conda run -n textgen pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Clone the repository
RUN git clone https://github.com/oobabooga/text-generation-webui

# Install the requirements
RUN cd text-generation-webui && \
    /opt/conda/bin/conda run -n textgen pip install -r requirements.txt && \
    chown -R root:root /app

# Set the working directory
WORKDIR /app/text-generation-webui

# Install extensions
RUN git clone https://github.com/xanthousm/text-gen-webui-ui_tweaks.git extensions/ui_tweaks && \
    git clone https://github.com/wawawario2/long_term_memory extensions/long_term_memory && \
    git clone https://github.com/innightwolfsleep/text-generation-webui-telegram_bot extensions/telegram_bot && \
    /opt/conda/bin/conda run -n textgen pip install -r extensions/long_term_memory/requirements.txt && \
    /opt/conda/bin/conda run -n textgen pip install -r extensions/telegram_bot/requirements.txt && \
    chown -R root:root /app && \
    find /app -type d -exec chmod 775 {} + && \
    mkdir /.cache && chmod 775 /.cache

# Create directories and symbolic links
RUN mkdir -p /data/models && \
    mkdir -p /data/characters && \
    cp -r /app/text-generation-webui/characters /app/text-generation-webui/characters.dist && \
    rm -r /app/text-generation-webui/models && \
    ln -s /data/models /app/text-generation-webui/models && \
    rm -r /app/text-generation-webui/characters && \
    ln -s /data/characters /app/text-generation-webui/characters && \
    chown -R root:root /data && \
    find /data -type d -exec chmod 775 {} +

# Add a script that creates the symbolic link and starts the server
ADD scripts/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Define the entrypoint
ENTRYPOINT ["/app/start.sh"]
# Use Node.js as base image since n8n requires Node.js
FROM node:18-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for python command
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install n8n globally
RUN npm install -g n8n

# Create n8n user and directories
RUN useradd -m -s /bin/bash n8n
RUN mkdir -p /home/n8n/.n8n
RUN chown -R n8n:n8n /home/n8n

# Switch to n8n user
USER n8n

# Set environment variables
ENV N8N_USER_FOLDER=/home/n8n/.n8n
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

# Expose n8n port
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Start n8n
CMD ["n8n", "start"]

FROM ghost:5.118.1
# Switch to root to install dependencies
USER root
COPY config.production.json /var/lib/ghost/config.production.json
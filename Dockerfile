# Use the official Ghost image as base
# FROM ghost:5.118.1

FROM ghost:5.118.1
# Switch to root to install dependencies
USER root


COPY 
# Install AWS CLI (optional, useful for debugging)
# RUN apt update && apt install -y \
#     python3 \
#     py3-pip \
#     && pip3 install --upgrade pip \
#     && pip3 install awscli

# # Install ghost-s3-compat and set up storage
# RUN mkdir -p /var/lib/ghost/content/storage \
#     && npm install ghost-s3-compat \
#     && cp -r node_modules/ghost-s3-compat /var/lib/ghost/content/storage/ghost-s3-compat \
#     && chown -R node:node /var/lib/ghost/content/storage

# COPY config.production.json /var/lib/ghost/config.production.json
# Install ghost-s3-compat and set up storage
RUN mkdir -p ./content/adapters/storage \
    && npm install ghost-storage-adapter-s3 \
    && cp -r ./node_modules/ghost-storage-adapter-s3 ./content/adapters/storage/s3



RUN apt update -y && apt install git -y && git clone https://github.com/bensoer/ghost-cache-adapter-redis.git \
    && cd ghost-cache-adapter-redis \
    && npm install \
    && npm run build \
    && cp -r ./dist/* ./content/adapters/cache/ghost-cache-adapter-redis




# Switch back to the 'node' user for security
# USER node

# Health check
# HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
#     CMD curl -f http://localhost:2368/ghost/api/admin/posts/ || exit 1

# # Default environment variables
# ENV NODE_ENV=production \
#     url=http://localhost:2368

# # Expose port 2368
# EXPOSE 2368

# # Start Ghost
# CMD ["node", "current/index.js"]
# ENTRYPOINT ["sleep", "infinity"]
# CMD []
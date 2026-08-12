FROM  quay.io/sclorg/nodejs-20-c9s@sha256:60dc5b48884980386bf8b54f9ab4633a7953f60506467e4bd614ba8ecf2c33b5 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:f550bb071fb8cf9a56f8f5bb9bcb0a1a58835a7d1ce2b85300c9cd4ce31d0720

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
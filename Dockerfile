FROM  quay.io/sclorg/nodejs-20-c9s@sha256:c0b7c665d87264e8baf136a82b91f52e306e6ad0ba7d7cf7d50c66bc33b6d71b AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:7a33fab3c7cd16dbf531414b654a3ac8ba3c071b44140ca34af12dddb4125665

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
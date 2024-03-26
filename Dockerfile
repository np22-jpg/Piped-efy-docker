FROM  quay.io/sclorg/nodejs-20-c9s@sha256:9deed70c39fa2f945ab43fb8b7f3033745aa2b6c751146f83cc029daceaecc62 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:3c803cfcdbbbe0c47a054f086499020ce81d6fc6e0938c2e537158ac432b7fb1

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:0f8a4a1aa343029842423c202d728e7b2064df164b94c80095fea36e851100e5 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:ec6e063e86cda4f083d62ee56f77db3aaf0c741d556d2b3844c44858dcb3022e

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
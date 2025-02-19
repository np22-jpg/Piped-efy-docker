FROM  quay.io/sclorg/nodejs-20-c9s@sha256:a2a5c0e89f5d1dbff5d6aac8f0270ffd49a8e7578d13a8cc2fb3a689b9081006 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b25063fec538477e0234b990620dde815444e0eceda8f9f56fcf421debda8248

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:1655e12813667062152b4ac0cf36c6a46a482833b6e24ce4f80cda1c505bf03d AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:d8215f72cc5f2787d9fde12fa0dda9b01fd7d44f6b406cbe76fa2b731df3208e

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
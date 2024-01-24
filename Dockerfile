FROM  quay.io/sclorg/nodejs-20-c9s@sha256:2b67c5dd33ffaafb5ccb659f2e11381fbd818f922477b2b92b3dbee0decabf43 AS build

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
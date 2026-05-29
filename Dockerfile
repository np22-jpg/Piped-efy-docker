FROM  quay.io/sclorg/nodejs-20-c9s@sha256:d9cd99d2af73c1b8c6fa83dc8e1098e59f43a9ac5c62bc320a04074b88fed46f AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:9b9612113c9f6274dbf1b34949c5268f6597ba3b50d441d1e14e2df67999f21f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
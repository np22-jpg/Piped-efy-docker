FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ddce9bee1670f0f98e1f64c84023d38a996c211bc41d731c4faf86c5a04a7275 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:512f99877e4309e652cffb05f317d235ab950862c7083d7ae2c89a709268a25f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
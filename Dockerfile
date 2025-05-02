FROM  quay.io/sclorg/nodejs-20-c9s@sha256:fcf0b5ce281fe5e5755049dbb08e3912853e95f2f80327771a27b7459957b4f4 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:92ba892b6e41a8e95a1d167b870281afd1c851a25073864198c9e00a8d73ec7b

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
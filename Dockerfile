FROM  quay.io/sclorg/nodejs-20-c9s@sha256:1d1f8402ca7788cdf0a6a5243856c23f9d2600a533d82e5420da3fbdb3545d00 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:3aaf26294a88c746193e63d6eea406c6cee08dcc086462df7e931e2c5b5c1d6d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
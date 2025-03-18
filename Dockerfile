FROM  quay.io/sclorg/nodejs-20-c9s@sha256:a3b5cce75a52d2c08326556f6a832abcfbafab3b6444713e8a85f0e3bd63c9af AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:2b46df4dd73c62ff3cd295710d508ef9fe8097a19892e5964e44046030e62597

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
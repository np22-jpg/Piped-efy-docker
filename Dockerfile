FROM  quay.io/sclorg/nodejs-20-c9s@sha256:2c5da3ff073cedc6926c06c91e4e722fb6cc0a35f1764959c5987334f67a2fd8 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:f7be28adda9be08eec0db4238cc66caf50184b6dc74b00fb3bf9a8746f476894

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
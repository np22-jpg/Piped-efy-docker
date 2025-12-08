FROM  quay.io/sclorg/nodejs-20-c9s@sha256:79d63156b491a9c9c274fe95c3d0a2ea79d494959ca7ec81c775035654ef2c58 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:9f0157e8b0bc387070aa54dea2c1fb2c36d398f4d68dd147949e5333b53c3d7c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
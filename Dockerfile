FROM  quay.io/sclorg/nodejs-20-c9s@sha256:4f1da5d46ae3c87ad2a0355a1e4b2f20c47e4af3bca28c4bc62b638827bd6117 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:2d76d3e588dea5577c60f4471c969b9e6abddfb84bd4a80d5abb046a27a0617e

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
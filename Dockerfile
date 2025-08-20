FROM  quay.io/sclorg/nodejs-20-c9s@sha256:e6aaecff699edc535926e8eb88f9fbee9e964a6183a314e2af1c26d9448e40cc AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:71e92836bf1be546abb4810dc7cb4eaf7d8c196a5ddece43f7efe8b669bb1145

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
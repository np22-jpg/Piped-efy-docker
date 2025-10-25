FROM  quay.io/sclorg/nodejs-20-c9s@sha256:cbd2bd9e061c15dcda83671abb7db567bd8dfabd516e2a5c04c38ce5e867bfd9 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:7735fe281257b0ad03d80379f84f54b23b11cc027b52717ccaecb9d111f10f03

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
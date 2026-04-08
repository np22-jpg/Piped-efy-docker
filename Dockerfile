FROM  quay.io/sclorg/nodejs-20-c9s@sha256:2ada93ac4bc3be4d33a334aaaa462d69b3aaf23c9354d0e107f774c5d3e907de AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:0c62ecdece259815859f78dc5d157fc71f8c5761fe88b688ccf28e2b8c29191c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
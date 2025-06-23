FROM  quay.io/sclorg/nodejs-20-c9s@sha256:d0e103e984de1ad5c01687a8a2ba75c77ad85e96d509676f4659c1d7903ccfdd AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:88bdaf7fae82d9e9f5e6683d8a403ebe0bb7978f4c3cb1114c824a292d72fe58

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
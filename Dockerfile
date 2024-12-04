FROM  quay.io/sclorg/nodejs-20-c9s@sha256:81d953c46168606268188c00ec241fec65ee7fe7dfa5ce2c524f91e73c2d169c AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:e47bc640e8c940701dba3107f53087022d864a03c88dec81d44c018f7de1f778

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
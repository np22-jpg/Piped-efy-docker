FROM  quay.io/sclorg/nodejs-20-c9s@sha256:527f8bc02a2af257d6b8454ccdb0096dc66ee9db928e74edab8f702fb9412d0f AS build

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
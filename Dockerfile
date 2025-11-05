FROM  quay.io/sclorg/nodejs-20-c9s@sha256:8f89e051b35a9acef5f4b180a7ebf5921c7e51f9f6f3a9694551f7401ea77394 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b8ff8a3792c7f2c407346f84be78e5b76ac5001a2fc7f6e273a81db1c785cb53

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
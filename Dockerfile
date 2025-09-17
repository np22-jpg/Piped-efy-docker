FROM  quay.io/sclorg/nodejs-20-c9s@sha256:85788559da8455ba7245063af24af3b39eef9836a08e31903236e0c48a518b29 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:8c0bd6c6d2106d74874a6353f391c71938bf5edbf4f36d15b263546904c1a0f4

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
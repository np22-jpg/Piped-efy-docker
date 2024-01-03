FROM  quay.io/sclorg/nodejs-20-c9s@sha256:0807440859f8c46de47a304f03e579eeb97272fd630c92d9695a2fdfb46da7d8 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b6bd662b5115a21d888ae42c925c99860e73f04095f16216f2a0aaf31ebc77f4

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
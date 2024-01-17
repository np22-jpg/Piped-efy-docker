FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ce2b71bba387f87b64cba89abe5ecac1ae9b75e0f515f40cd87521706501fad1 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:066103de898363634a8164a49e5919e90c38e033b17c205f72f39c678adeea6c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:4dfe13112cb7f7e779628bbddd808098dfc98bd9cd3280858fcaf86be2029244 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:58ef382eea3a8f59c5d11b31e749ecb5a00edfbe9c8255cc3f79576385917ff1

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
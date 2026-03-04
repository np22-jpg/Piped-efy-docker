FROM  quay.io/sclorg/nodejs-20-c9s@sha256:f7e82bb749b83f28a5e856f32c56906f0534bfb0a372da61b8761900ced06668 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:185d49b5169bd6939cd58cab11ff2f6e38a275dc8916b85db3ec1f412f5e5827

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
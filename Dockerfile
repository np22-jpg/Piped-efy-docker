FROM  quay.io/sclorg/nodejs-20-c9s@sha256:c04df17cc49788933e36df5ffe014c7ba118023a41aa50a15e3ca541f096c619 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:1f3a36e48358fc1b750da974e988ce0a218aa374e027fef01f0c5a4f67e81bb0

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
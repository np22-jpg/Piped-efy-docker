FROM  quay.io/sclorg/nodejs-20-c9s@sha256:6500f27900ce994b28d4afe441001fa5841cfc8d48a4c764db4cbfb28be698cf AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b2c5e832e4bb42a742af0cd36354ecc2f057cc4a8666e18035c54d8fb3a6e2d0

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
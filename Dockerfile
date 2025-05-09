FROM  quay.io/sclorg/nodejs-20-c9s@sha256:107c72e07b8f9b997ebbbd1dc180610b099c40dd51241d587b593588049cca00 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:ddd3652120a212be218671274839ea014654f96f58586ef25fcc10cc400430ce

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:2115102e482971b7d95e65087859f1d7dbc506183f51254894b381a356b54e19 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:98ec07221c704196bb487ab4d8cc90bba51c20ecaa8bfb2e51cebd2485fb4081

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
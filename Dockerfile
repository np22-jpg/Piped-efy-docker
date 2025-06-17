FROM  quay.io/sclorg/nodejs-20-c9s@sha256:0046791c436b6d5c40720d9ca0fdc0de267550af991fd6f05bf96767d24c3a66 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:73d919221d45dc04e78798ca22f4265dcdd5cdcb6cf63d16604cf40060f1d41d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
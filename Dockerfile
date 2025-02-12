FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b92d9d7617496288676478e8a487126f50e3a6cf3da989e2e0e3c38edb4aa80e AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:0d66f8393150745078b0ce7ba53d0f507f274f8eea953d302985d1ef699d3513

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
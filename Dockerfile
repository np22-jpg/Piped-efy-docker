FROM  quay.io/sclorg/nodejs-20-c9s@sha256:98a74d97e79f78c37cda453892aa00594a194a58a9c549de210aaf2d241e15d3 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:31b5c11e70957e2e6eb32c0c1f9ba5c2ce8cff105aa23a99b946fa4242d15178

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
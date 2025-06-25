FROM  quay.io/sclorg/nodejs-20-c9s@sha256:f7c48deadc2655b5d0e75b82bfca90c058d0dbc4e2587a88c5b99afebeaee381 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:4ac75d8aba9b2a755cff7972eefd8a4140d05f6d52e991359c353041ce0312f6

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
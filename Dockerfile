FROM  quay.io/sclorg/nodejs-20-c9s@sha256:2203f1303f82292491d078c5aeccd0ce996376e6785d930aa7aaac50b39772b5 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:e64ac6b3a93053695f0d4fe57d96918c66c7b6d9242b6cf67fb389d988eea3ab

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
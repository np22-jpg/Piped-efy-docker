FROM  quay.io/sclorg/nodejs-20-c9s@sha256:dab18c488bb953621c23129c55f7c984b0020118ab8907b5d205f1c77e4cb8f0 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:6b6e0ae345a84eee46e33063b3ce4ae20b9094a15438870d426594045956d772

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
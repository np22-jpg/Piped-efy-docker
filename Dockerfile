FROM  quay.io/sclorg/nodejs-20-c9s@sha256:e6d5189ad6fad58edb0ef73ef641de75a9f4b3b08298d1687bfe1c0d3e4c0b52 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:463cdce4cf1b7ce9b6c491690eb2ec85c71517680ecaf261df8651a5f93ff4df

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
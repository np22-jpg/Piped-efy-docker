FROM  quay.io/sclorg/nodejs-20-c9s@sha256:70dbeef0f734525e7158905cea0ae43a29d79cee8971f25451d6a6b83601c7e7 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b621b962046ada6cfa1adeda174a434f8356ca594ce5c34675b89353d5453a87

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:f2be8611e0fb224728456bfe703bb631de8e1b8dc7200f5a8a9996a9eb3ed11e AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:335517dc49202b4c92173fa3f040979f49b07212603715323d1bcc13f56f2843

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
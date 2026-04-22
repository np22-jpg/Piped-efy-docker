FROM  quay.io/sclorg/nodejs-20-c9s@sha256:3ba57ce548f10598fc43d2c005b9a9c0ff6d1b38ac6d99cd871b077b76b1fc1a AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:5a5756d7149f11eb8971d6144d0c40c129a03a8a31df8b3b4994b07e1051cf03

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
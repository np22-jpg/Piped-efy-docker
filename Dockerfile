FROM  quay.io/sclorg/nodejs-20-c9s@sha256:d1ab2463d70b5c928d84085ece5ee589e9a545ed6b7ce2909170d25302374f16 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:eece92b4c9138acb1084648ed95f5f60b92e4c33488bd9e83c157c2b6e6f5ec9

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:5f71767f5b1240d03c607b0fe5f01185bac9c7fb59359b4f79820f32bbcea22d AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:c35de63b09211950166cc442d7da9900ad82f85a892fbdd47d8578952d3de4ed

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
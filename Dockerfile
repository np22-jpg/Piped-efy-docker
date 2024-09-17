FROM  quay.io/sclorg/nodejs-20-c9s@sha256:3b0870b6de402f590a9c43d28954ad8fd0d814a0f6c57e3a1c865ad16eb1369b AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:e170bc7554e802f2d2778ae56d116866e3c632842092533b5baebb41d20df4c5

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
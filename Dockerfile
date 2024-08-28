FROM  quay.io/sclorg/nodejs-20-c9s@sha256:6297f057bd2eaa365d7715530d68366ec2e94aabce9cc969e027b5c387b44297 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:c9be51076c5c8779c415e45e1df15bc1205cdae9b8d66d5d1c9929b6ed32cfd4

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
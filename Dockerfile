FROM  quay.io/sclorg/nodejs-20-c9s@sha256:31bb5e0630a222ceb99374f50263442bf5259a483e3c694ef28b3d11bfc21e5e AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:8762219cc0100f40bb1b5aeeb4b3936fec219fb9dd8bcb71fc64d5273a59461d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
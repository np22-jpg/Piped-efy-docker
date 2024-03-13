FROM  quay.io/sclorg/nodejs-20-c9s@sha256:f43282b46cf5d2596c5ac0faab31c09824c36f020805615d287bf3276d804f70 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:02db7fe64ff18a46753d9bd43c9bdf21f07c2a45828a1dd791d2daa53dc9a1a8

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
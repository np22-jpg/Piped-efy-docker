FROM  quay.io/sclorg/nodejs-20-c9s@sha256:2c5da3ff073cedc6926c06c91e4e722fb6cc0a35f1764959c5987334f67a2fd8 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:23c43036ae911ae9db9ed995c998e5e1414d335854ea5be896cb00374d978054

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
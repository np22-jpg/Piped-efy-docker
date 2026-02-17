FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b44e82ba241fccaadf1205bb71881c2c5936f9cc27ba555b332924e5bb3cce66 AS build

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
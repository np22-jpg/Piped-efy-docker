FROM  quay.io/sclorg/nodejs-20-c9s@sha256:918f413cb9758df8738f8b4615dffbf59f0d4d10ed9afd32f741645d062a9fe1 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:bccb3a09d4840797e7a3831676d209427a6322c1b456823676578fd04da4111d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
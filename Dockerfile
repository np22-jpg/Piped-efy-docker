FROM  quay.io/sclorg/nodejs-20-c9s@sha256:3ac3db0446b408ae735f08eca632061b55235e36e7b0f878a39ac607252d959f AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:a1518ea1add9590d0b4d814ebc9d341db86f91c4ab9d0016a28cca1a48cff02f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
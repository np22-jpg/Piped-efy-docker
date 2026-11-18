FROM  quay.io/sclorg/nodejs-20-c9s@sha256:3fb57e72abccc6c3097c894bb5e1845c232626cc589ba2acdb7736d4e7ba2448 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:6cf8db91a8eacc74da4e9c8457be00bcac7a6ab0934943845e170480ddf62bb5

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
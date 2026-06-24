FROM  quay.io/sclorg/nodejs-20-c9s@sha256:698ae7ec81ef13847cdf0e97860a80d00f8bd4904f1037233b392e972f2492da AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:2c7601130c452939e0d2410118e184135d2c4bec1425f36519e33a1288ac803e

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
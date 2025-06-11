FROM  quay.io/sclorg/nodejs-20-c9s@sha256:a5d751324a724db7b2f7ba59061a6bcd2d68cac6165f2eaf805577d81c58bca1 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:1bbdcef54e566a1226f8c6ea07243a650596d8abf6b554e18c9d93e5298b83fc

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
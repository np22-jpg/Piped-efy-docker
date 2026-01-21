FROM  quay.io/sclorg/nodejs-20-c9s@sha256:d141dc7ee127bea97b854ff1dd280165c358f2fc9c5b62d1cb281bc6011672a5 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:cea0fea75726d75f139b931341aa2bdbf80260c95e485493d94362586827b9b3

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:533f27b25798e0eee55f850d3c733b83b190a396389845289df96ede1ea81237 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:664f9d6eb29f938cba13b0b13425fe8babe37f583706b87df7e3697b1302818d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
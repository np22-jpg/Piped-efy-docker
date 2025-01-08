FROM  quay.io/sclorg/nodejs-20-c9s@sha256:cb57363f86cc5c7473d4f54b4d3a110e06aab85f2ab3651225ac4f08dd4813fd AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:d6fc49904e65a7ceb0f10f33c9ad63c89215c855bb1c38427191e3ad38202ca2

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM  quay.io/sclorg/nodejs-20-c9s@sha256:1cd07f35d16ff0940b2916a75d0f8e80c29d5bb3a8f1712912b22f9c8c7500b6 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:380897d3da64c50d02195349ada8482d0903b0f5df90f095ebc286b682649292

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
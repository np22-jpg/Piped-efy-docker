FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ae7b79ac83b5504771d55d579a6212f8ac46a249854d9259a7387039398f233d AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:4476b90bfe2409c70fff5143e343fa0a06e874f7d13402c5942e04a049bcb61c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
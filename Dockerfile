FROM  quay.io/sclorg/nodejs-20-c9s@sha256:8cbca93953006464ba0d80845672faee741c09be327c4b519526c6361f128d86 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:9e112fc0fb822631ff3314fcda481e683417f3985af06b6492b6ae55127b6aee

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
FROM registry.access.redhat.com/ubi9/nodejs-20@sha256:399418ca8d804ee6a7a96a0fb58d6b4a7318da427b0d61a3d6b0bb3ad964ab31 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM registry.access.redhat.com/ubi9/nginx-122@sha256:8835e45b874bc92650b1f8faf23f5c525c8ca4ebbf6b5e97d58c084cfc5a099a AS release

COPY --from=build /app/dist/ /tmp/src/

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

RUN sed -i s/pipedapi.kavin.rocks/pipedapi.nolanpoe.me/g ${APP_ROOT}/src/assets/*

EXPOSE 8080
# Run script uses standard ways to run the application
CMD [ "/usr/libexec/s2i/run" ]
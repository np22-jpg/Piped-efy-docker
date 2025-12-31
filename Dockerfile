FROM  quay.io/sclorg/nodejs-20-c9s@sha256:717fa1f2cb017a785f430a243b60c69def35e323c3e945b81583ed258b209c8f AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:6dcd3df290a6daf532740af945929b7c87b1207b5d51520e79e7356107e52def

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
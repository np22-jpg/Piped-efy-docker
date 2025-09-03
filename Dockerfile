FROM  quay.io/sclorg/nodejs-20-c9s@sha256:935db93a331df250b75dd9385933ece792920b25027d03c7318a940a2789839a AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:81ee6810ad86625c26b8fac3fa0b819fef8b7a379433fe069adcba9ce9f71901

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run
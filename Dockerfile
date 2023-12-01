FROM node:lts-alpine@sha256:b1789b7be6aa16afd642eaaaccdeeeb33bd8f08e69b3d27d931aa9665b731f01 AS build

WORKDIR /app/

RUN apk add --no-cache \
    curl

COPY . .

RUN corepack enable && corepack prepare pnpm@latest --activate

RUN pnpm install && \
    pnpm build

FROM nginx:alpine-slim@sha256:4716bad84614d17f0159a769c337c00aae1c62100583bcf8b72b76e6861daea4

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

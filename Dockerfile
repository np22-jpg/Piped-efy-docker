FROM node:lts-alpine@sha256:b1789b7be6aa16afd642eaaaccdeeeb33bd8f08e69b3d27d931aa9665b731f01 AS build

WORKDIR /app/

RUN apk add --no-cache \
    curl

COPY . .

RUN corepack enable && corepack prepare pnpm@latest --activate

RUN pnpm install && \
    pnpm build

FROM nginx:alpine-slim@sha256:d45f4c998198583de669cd0ea8ab819ab344d57d6bf42b6f121d0ec097a032e8

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

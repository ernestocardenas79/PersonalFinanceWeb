ARG NGINX_VERSION=1.29-alpine
# ---------- Build Stage ----------
FROM node:24-alpine AS build
LABEL org.opencontainers.image.title="Personal Finance Web"
LABEL org.opencontainers.image.description="Personal Finance SPA"
LABEL org.opencontainers.image.source="https://github.com/ernestocardenas79/PersonalFinanceWeb"
LABEL org.opencontainers.image.vendor="Cats Lair"
LABEL org.opencontainers.image.licenses="MIT"

WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

# ---------- Runtime Stage ----------
FROM nginx:${NGINX_VERSION}

COPY --from=build /app/dist/personal-finance-web/browser /usr/share/nginx/html

RUN printf '%s\n' \
'server {' \
'    listen 80;' \
'    server_name _;' \
'    root /usr/share/nginx/html;' \
'    index index.html;' \
'    location / {' \
'        try_files $uri $uri/ /index.html;' \
'    }' \
'}' \
> /etc/nginx/conf.d/default.conf

EXPOSE 80

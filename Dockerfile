FROM node:24.2-alpine3.21 AS builder

LABEL org.opencontainers.image.source="https://github.com/lyazide/cda242-next"

# Need for debian12
# RUN apt-get update -yq \
#     && apt-get install curl gnupg -yq \
#     && curl -sL https://deb.nodesource.com/setup_24.x | bash \
#     && apt-get install nodejs -yq \
#     && apt-get clean -y

ADD . /app

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install --omit=dev

RUN npm run build

FROM node:24.2-alpine3.21 AS next

EXPOSE 3000

WORKDIR /app

# Copie uniquement les fichiers indispensables pour l'exécution
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public


COPY docker/next/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT [ "entrypoint" ]
CMD [ "npm", "run", "start"]

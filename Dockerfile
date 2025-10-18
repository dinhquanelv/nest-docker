FROM node:22.20-alpine AS build-stage

WORKDIR /app

RUN npm i -g pnpm

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm prisma generate
RUN pnpm build

FROM node:22.20-alpine AS prod-stage

WORKDIR /app

RUN npm i -g pnpm

COPY --from=build-stage /app/dist ./dist
COPY --from=build-stage /app/prisma ./prisma
COPY --from=build-stage /app/package.json /app/package.json
COPY --from=build-stage /app/pnpm-lock.yaml /app/pnpm-lock.yaml

RUN pnpm install --production --frozen-lockfile

EXPOSE 3000

CMD ["pnpm", "start:prod"]
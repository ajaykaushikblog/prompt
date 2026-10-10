FROM node:22-alpine AS build
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm exec vite build --config vite.production.config.ts
RUN pnpm build:next
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV USE_NEXT=true
ENV NEXT_TELEMETRY_DISABLED=1
COPY --from=build /app/package.json /app/pnpm-lock.yaml ./
RUN corepack enable && pnpm install --prod --frozen-lockfile
COPY --from=build /app/dist ./dist
COPY --from=build /app/next-app ./next-app
COPY public ./next-app/public
COPY server ./server
COPY database ./database
COPY scripts ./scripts
COPY src/data.ts ./src/data.ts
RUN mkdir -p /app/uploads /app/private-files && chown node:node /app/uploads /app/private-files
USER node
EXPOSE 3000
CMD ["node","server/index.mjs"]

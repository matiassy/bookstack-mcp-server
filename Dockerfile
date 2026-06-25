FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build && npm prune --omit=dev

# ---

FROM node:20-alpine AS runtime

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json ./

ENV NODE_ENV=production
ENV MCP_TRANSPORT=http
ENV SERVER_PORT=3000

EXPOSE 3000

CMD ["node", "dist/server.js"]

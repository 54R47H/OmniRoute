# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY package*.json ./
COPY scripts ./scripts

RUN npm ci --legacy-peer-deps --ignore-scripts

COPY . .

ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build

# Production Stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --legacy-peer-deps --omit=dev --ignore-scripts

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/main.js"]

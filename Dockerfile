# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app

# SQLite-ന് ആവശ്യമായ ബിൽഡ് ടൂളുകൾ
RUN apk add --no-cache python3 make g++ sqlite-dev

COPY package*.json ./
COPY scripts ./scripts

# ഡിപൻഡൻസികളും ഒപ്പം better-sqlite3-ഉം ഇൻസ്റ്റാൾ ചെയ്യുന്നു
RUN npm ci --legacy-peer-deps --ignore-scripts
RUN npm install better-sqlite3 --no-save --legacy-peer-deps

COPY . .

# ചെക്ക് സ്കിപ്പ് ചെയ്യാനും മെമ്മറി കൂട്ടാനുമുള്ള എൻവയോൺമെന്റ് വേരിയബിളുകൾ
ENV OMNIROUTE_SKIP_NATIVE_DEP_CHECK=1
ENV NODE_OPTIONS="--max-old-space-size=4096"

RUN npm run build

# Production Stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

RUN apk add --no-cache sqlite-libs

COPY package*.json ./
RUN npm ci --legacy-peer-deps --omit=dev --ignore-scripts
RUN npm install better-sqlite3 --no-save --legacy-peer-deps

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/main.js"]

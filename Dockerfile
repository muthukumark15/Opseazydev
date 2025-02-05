FROM --platform=linux/amd64 node:alpine AS deps
 
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json ./
RUN yarn install --frozen-lockfile
 
 
FROM --platform=linux/amd64 node:alpine AS builder
 
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN yarn build
 
FROM --platform=linux/amd64 node:alpine AS runner
 
WORKDIR /app
 
ENV NODE_ENV production
 
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
 
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
RUN chown -R nextjs:nodejs /app/.next
USER nextjs
 
EXPOSE 8080
 
CMD ["yarn", "start"]
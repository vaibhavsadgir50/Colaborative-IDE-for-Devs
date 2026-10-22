FROM node:20-alpine as frondend-builder
COPY ./Frontend /app

WORKDIR /app

RUN npm install

RUN npm run build

#backend
FROM node:20-alpine

COPY ./Backend /app

WORKDIR /app

RUN npm install

COPY --from=frondend-builder /app/dist  /app/public

CMD ["node", "server.js"]
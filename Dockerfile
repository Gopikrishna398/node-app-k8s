FROM node:24-bookworm-slim

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000 3000
CMD ["node" ,"server.js"]

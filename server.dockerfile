FROM node:20

WORKDIR /app

COPY server/paveguard-webserver/package*.json ./

RUN npm install

COPY server/paveguard-webserver .

RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start:prod"]

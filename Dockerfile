FROM node:16
WORKDIR /usr/src/app
COPY app/package*.json ./
RUN npm install
COPY . .
WORKDIR /usr/src/app/app
EXPOSE 3000

CMD [""]

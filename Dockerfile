FROM node:8

WORKDIR /app 

COPY package.json package.json

COPY package-lock.json package-lock.json

RUN npm install

COPY . . 

EXPOSE 3000 

RUN npm install -g nodemon 

CMD [ "nodemon", "auth-server/server.js" ] 
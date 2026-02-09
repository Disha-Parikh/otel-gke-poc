FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npn install
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]

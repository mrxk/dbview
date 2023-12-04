FROM node:21-alpine3.17
COPY html /app/html
COPY server /app/server
RUN cd /app/server && npm install
WORKDIR /app/server
CMD ["node", "./main.js" ]

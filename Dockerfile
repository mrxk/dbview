FROM node:21-alpine3.17
RUN apk add curl
RUN curl -L -o /tmp/elm.gz https://github.com/elm/compiler/releases/download/0.19.0/binary-for-linux-64-bit.gz
RUN gunzip /tmp/elm.gz
RUN chmod +x /tmp/elm
RUN mv /tmp/elm /usr/local/bin/
COPY client /app/client
COPY html /app/html
COPY server /app/server
RUN cd /app/server && npm install
RUN cd /app/client && elm make src/Main.elm --output ../html/elm.js
WORKDIR /app/server
CMD ["node", "./main.js" ]

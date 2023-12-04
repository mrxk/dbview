
FROM node:21-alpine3.17
LABEL creator=dev-env
RUN npm install elm-format -g
RUN apk add curl
RUN curl -L -o /tmp/elm.gz https://github.com/elm/compiler/releases/download/0.19.0/binary-for-linux-64-bit.gz
RUN gunzip /tmp/elm.gz
RUN chmod +x /tmp/elm
RUN mv /tmp/elm /usr/local/bin/
ENTRYPOINT ["/bin/ash"]

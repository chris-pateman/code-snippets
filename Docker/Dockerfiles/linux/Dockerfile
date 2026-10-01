FROM ubuntu as os
FROM mcr.microsoft.com/azure-cli:latest AS az-img
WORKDIR /app
ENTRYPOINT [ "bash" ]
RUN apk add install ssh
RUN systemctl ssh start
RUN systemctl ssh enable
RUN service ssh status
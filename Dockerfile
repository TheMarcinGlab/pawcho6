# syntax=docker/dockerfile:1

########## Etap 1: Budowanie aplikacji Node.js ##########
FROM scratch AS builder

# Dodajemy system plików Alpine-minirootfs
ADD alpine-minirootfs-3.21.3-x86_64.tar /

# Aktualizacja repozytoriów i instalacja Node.js oraz iproute2
RUN apk update && apk add --no-cache nodejs iproute2

WORKDIR /app

# Kopiujemy skrypt generujący stronę
COPY info.js .

########## Etap 2: Konfiguracja serwera Nginx z dynamicznym generowaniem strony ##########
FROM nginx:stable-alpine

#inne arg i env(zalecane)
ARG VERSION
ENV VERSION=${VERSION}

# Instalacja Node.js oraz curl
RUN apk update && apk add --no-cache nodejs npm curl

# Kopiujemy konfigurację Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Kopiujemy aplikację (skrypt info.js) z etapu budowania
COPY --from=builder /app /app

# Kopiujemy skrypt startowy, który dynamicznie generuje stronę przy starcie kontenera
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

# Ujednolicony mechanizm HEALTHCHECK korzystający z dedykowanego endpointu /health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD curl -s http://localhost/health | grep -q "OK" || exit 1

ENTRYPOINT ["/entrypoint.sh"]

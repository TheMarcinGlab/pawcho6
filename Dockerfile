# syntax=docker/dockerfile:1

##############################################
# Etap 1: Klonowanie repozytorium przez SSH
##############################################
FROM alpine/git AS repo

RUN mkdir -p /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts
# Użycie mount=type=ssh umożliwia przekazanie klucza SSH podczas budowania
RUN --mount=type=ssh git clone git@github.com:themarcinglab/pawcho6.git /repo

##############################################
# Etap 2: Budowanie aplikacji Node.js (kod z repozytorium)
##############################################
FROM scratch AS builder
# Dodajemy system plików Alpine-minirootfs (upewnij się, że plik jest aktualny)
ADD alpine-minirootfs-3.21.3-x86_64.tar /
# Aktualizacja repozytoriów i instalacja Node.js oraz iproute2
RUN apk update && apk add --no-cache nodejs iproute2
WORKDIR /app
# Kopiujemy plik aplikacji z repozytorium (np. info.js)
COPY --from=repo /repo/info.js .

##############################################
# Etap 3: Konfiguracja serwera Nginx z dynamicznym generowaniem strony
##############################################
FROM nginx:stable-alpine
# Przyjmujemy argument VERSION i ustawiamy zmienną środowiskową
ARG VERSION
ENV VERSION=${VERSION}
# Instalacja dodatkowych narzędzi: Node.js, npm oraz curl
RUN apk update && apk add --no-cache nodejs npm curl
# Kopiujemy konfigurację Nginx z repozytorium
COPY --from=repo /repo/nginx.conf /etc/nginx/nginx.conf
# Kopiujemy skrypt startowy z repozytorium
COPY --from=repo /repo/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Kopiujemy aplikację z etapu builder
COPY --from=builder /app /app
EXPOSE 80
# Ujednolicony mechanizm HEALTHCHECK korzystający z dedykowanego endpointu /health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD curl -s http://localhost/health | grep -q "OK" || exit 1
ENTRYPOINT ["/entrypoint.sh"]

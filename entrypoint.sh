#!/bin/sh
echo "Generowanie dynamicznej strony index.html..."
node /app/info.js generate > /usr/share/nginx/html/index.html

echo "Uruchamianie serwera Nginx..."
exec nginx -g "daemon off;"

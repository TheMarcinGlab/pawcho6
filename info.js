const { networkInterfaces, hostname } = require('os');

const version = process.env.VERSION || 'nieokreślona';
const interfaces = networkInterfaces();
let ip = 'nieznany';

for (const name in interfaces) {
  for (const iface of interfaces[name]) {
    if (iface.family === 'IPv4' && !iface.internal) {
      ip = iface.address;
      break;
    }
  }
  if (ip !== 'nieznany') break;
}

console.log(`
<html>
  <head>
    <title>Informacje o serwerze</title>
  </head>
  <body>
    <h1>Dane z serwera</h1>
    <p>Adres IP: ${ip}</p>
    <p>Hostname: ${hostname()}</p>
    <p>Wersja aplikacji: ${version}</p>
  </body>
</html>
`);

const express = require('express');
const request = require('request');
const cors = require('cors');

const app = express();
app.use(cors()); // Habilita CORS

app.get('/proxy', (req, res) => {
  const url = req.query.url; // La URL que quieres solicitar
  request(url).pipe(res); // Redirige la solicitud al URL indicado
});

const PORT = 3000; // Puerto para el servidor proxy
app.listen(PORT, () => {
  console.log(`Proxy server listening on port ${PORT}`);
});

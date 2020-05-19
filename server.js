const path = require('path');
const express = require('express');
const mustacheExpress = require('mustache-express');

const { generatePdf, getData } = require('./invoice');

const app = express();

app.engine('html', mustacheExpress());
app.set('view engine', 'html');

app.use(express.static(path.join(__dirname, 'public')));

app.get('/export/html', (req, res) => {
  const data = getData('./config.json');
  res.render('template.html', data);
});

app.get('/export/pdf', (req, res) => {
  generatePdf().then(buffer => {
    res.set({ 'Content-Type': 'application/pdf', 'Content-Length': buffer.length });
    res.send(buffer);
  });
});

app.listen(3000);
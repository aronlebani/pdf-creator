const path = require('path');
const express = require('express');
const mustacheExpress = require('mustache-express');

const { generatePdf, getData } = require('./pdf');

const PORT = 3000;

const app = express();

app.engine('html', mustacheExpress());
app.set('view engine', 'html');
app.set('port', PORT);

app.use(express.static(path.join(__dirname, 'public')));

app.get('/export/html', (req, res) => {
  const data = getData(req.query.config);
  res.render('template.html', data);
});

app.get('/export/pdf', (req, res) => {
  generatePdf(`http://localhost:3000/export/html?config=${req.query.config}`)
    .then(buffer => {
      res.set({ 'Content-Type': 'application/pdf', 'Content-Length': buffer.length });
      res.send(buffer);
    });
});

app.listen(app.get('port'), () => {
  console.log(`Running on *:${app.get('port')}`)
});

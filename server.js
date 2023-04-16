const path = require('path');
const express = require('express');
const mustacheExpress = require('mustache-express');

const { generatePdf, generatePdfFromString, getData } = require('./pdf');
const { mdToHtml } = require('./md');

const PORT = 3000;

const app = express();

app.engine('html', mustacheExpress());
app.set('view engine', 'html');
app.set('port', PORT);

app.use(express.static(path.join(__dirname, 'public')));

app.get('/invoice/_', (req, res) => {
  const data = getData(req.query.config);
  res.render('template.html', data);
});

app.get('/invoice', (req, res) => {
  generatePdf(`http://localhost:3000/invoice/_?config=${req.query.config}`)
    .then(buffer => {
      res.set({ 'Content-Type': 'application/pdf', 'Content-Length': buffer.length });
      res.send(buffer);
    });
});

app.get('/markdown', (req, res) => {
  generatePdfFromString(mdToHtml(req.query.md))
    .then(buffer => {
      res.set({ 'Content-Type': 'application/pdf', 'Content-Length': buffer.length });
      res.send(buffer);
    });
});

app.listen(app.get('port'), () => {
  console.log(`Running on *:${app.get('port')}`)
});

const path = require('path');
const fs = require('fs');
const express = require('express');
const mustacheExpress = require('mustache-express');
const puppeteer = require('puppeteer');

const app = express();

const generatePdf = async () => {
  const browser = await puppeteer.launch();

  const page = await browser.newPage();
  await page.goto('http://localhost:3000/export/html', { waitUntil: 'networkidle0' });

  const buffer = await page.pdf({ format: 'A4' });

  await browser.close();
  
  return buffer;
}

const deriveData = (data) => {
  data.items.forEach(item => {
    item.total = item.hours * item.rate;
  });
  data.subTotal = data.items.reduce((a, b) => a.total + b.total);
  data.gst = data.subTotal * 0.1;
  data.total = data.subTotal * 1.1;

  return data;
}

app.engine('html', mustacheExpress());
app.set('view engine', 'html');

app.use(express.static(path.join(__dirname, 'public')));

app.get('/export/html', (req, res) => {
  const data = deriveData(JSON.parse(fs.readFileSync('./data.json')));
  res.render('template.html', data);
});

app.get('/export/pdf', (req, res) => {
  generatePdf().then(buffer => {
    res.set({ 'Content-Type': 'application/pdf', 'Content-Length': buffer.length });
    res.send(buffer);
  });
});

app.listen(3000);
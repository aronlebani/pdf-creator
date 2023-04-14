const fs = require('fs');
const puppeteer = require('puppeteer');

const formatCurrency = (amount) => {
  return `${(Math.round(amount * 100) / 100).toFixed(2)}`;
}

const generatePdf = async (url) => {
  const browser = await puppeteer.launch();

  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle0' });

  const buffer = await page.pdf({ format: 'A4' });

  await browser.close();
  
  return buffer;
}

const getData = (configPath) => {
  const data = JSON.parse(fs.readFileSync(configPath));

  const totals = data.items.map(item => item.hours * item.rate);
  const subTotal = formatCurrency(totals.reduce((a, b) => a + b));
  const gst = data.gstIncluded ? 'Included' : formatCurrency(subTotal * 0.1);
  const total = data.gstIncluded ? formatCurrency(subTotal) : formatCurrency(subTotal * 1.1);
  const items = data.items.map(item => ({ ...item, total: formatCurrency(item.hours * item.rate) }));

  return {
    ...data,
    subTotal,
    gst,
    total,
    items,
  };
}

module.exports = { generatePdf, getData };

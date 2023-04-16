const puppeteer = require('puppeteer');

const generatePdf = async (url) => {
  const browser = await puppeteer.launch();

  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle0' });

  const buffer = await page.pdf({ format: 'A4' });

  await browser.close();
  
  return buffer;
}

const generatePdfFromString = async (html) => {
  const browser = await puppeteer.launch();

  const page = await browser.newPage();
  await page.setContent(html);

  const buffer = await page.pdf({ format: 'A4' });

  await browser.close();
  
  return buffer;
}

module.exports = { generatePdf, generatePdfFromString };

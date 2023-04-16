const fs = require('fs');

const formatCurrency = (amount) => {
  return `${(Math.round(amount * 100) / 100).toFixed(2)}`;
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

module.exports = { getData };

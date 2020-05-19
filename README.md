# invoice-generator
Generates pdf invoices from config data.

# Usage
1. Create a `config.json` file in the root directory with the following contents:
```
{
  me: {
    name,
    addrLine1,
    addrLine2,
    addrLine3,
  },
  client: {
    name,
    addr,
    phone,
    abn,
  },
  invoiceNo,
  date,
  items: [{
    name,
    hours,
    rate
  }],
  payment: {
    name,
    bsb,
    accountNo,
  },
}
```
2. Run the server and go to `localhost:3000/invoice/pdf` in a browser.
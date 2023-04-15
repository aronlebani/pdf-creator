# invoice-generator
Generates pdf invoices from config data.

## Usage
1. Create a `json` file with the following contents:
```json
{
  "me": {
    "name": "example",
    "addrLine1": "1 Example Street",
    "addrLine2": "Suburb 3056",
    "country": "Australia",
    "abn": "11 111 111 111"
  },
  "client": {
    "name": "Example Client",
    "phone": "0411 111 111",
    "abn": "11 111 111 111"
  },
  "invoiceNo": "123456",
  "date": "14/04/2023",
  "items": [{
    "name": "Develop website",
    "hours": 16,
    "rate": 40
  }],
  "payment": {
    "name": "Account Name",
    "bsb": "123-456",
    "accountNo": "123456789"
  }
}
```
2. Run the server and navigate to `http://localhost:3000/invoice/pdf?config=<path-to-config-file>.json` in a browser.

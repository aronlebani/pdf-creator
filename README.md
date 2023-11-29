# pdf-creator

Generates pdf files from config data.

## Usage

### Generate invoice

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
2. Run the server `npm run start`
3. Navigate to `http://localhost:3000/invoice?config=<path-to-config-file>.json` in a browser

### Generate pdf from markdown

1. Create a `md` file
2. Run the server `npm run start`
3. Navigate to `http://localhost:3000/markdown?md=<path-to-md-file>.md` in a browser

You can add styling to the markdown export by adding a `style` tag to your markdown document, for example:
```html
<style>
    body {
        font-family: serif;
        font-size: 12px;
        line-height: 1.5;
        width: 8.3in;
        height: 11.6in;
        padding: 0.8in;
    }
</style>
```

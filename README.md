# pdf-creator

Generates pdf files from config data.

## Usage

Inside the project directory, run `bundle install`. To see usage options, run:

```
ruby lib/main.rb --help
```

## Examples

### Generate invoice

To generate an invoice create a json configuration file, and run

```
ruby lib/main.rb --config=<path-to-json>
```

Example config file:

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
    "rate": 3
  }],
  "payment": {
    "name": "Account Name",
    "bsb": "123-456",
    "accountNo": "123456789"
  }
}
```

### Generate pdf from markdown

Create a markdown file and run

```
ruby lib/main.rb --md=<path-to-md>
```

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

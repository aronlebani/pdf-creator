# pdf-creator

Generates pdf files from text files.

## Usage

Inside the project directory, run `bundle install`. To see usage options, run:

    ruby lib/main.rb --help

## Examples

### Generate invoice

To generate an invoice create a configuration file, and run

    ruby lib/main.rb --config=<path-to-config>

Example config file:

    number = "inv123456"
    date = "09/08/2024"

    [me]
    name = "Websites R Us"
    addrline1 = "1 Example Street"
    addrline2 = "Exampleville 3000"
    country = "Australia"
    abn = "11 111 111 111"

    [client]
    company = "ACME Pty. Ltd."
    phone = "0499 999 999"
    abn = "99 999 999 999"

    [[items]]
    hours = 16
    rate = 3.00
    description = "Build website for acme.com"

    [[items]]
    hours = 4
    rate = 2.00
    description = "Testing"

    [[items]]
    hours = 3
    rate = 2.00
    description = "Deploy website"

    [payment]
    bsb = "123-456"
    accname = "Aron Lebani"
    accnumber = "123 456 789"

### Generate pdf from markdown

Create a markdown file and run

    ruby lib/main.rb --md=<path-to-md>

You can add styling to the markdown export by adding a `style` tag to your
markdown document, for example:

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


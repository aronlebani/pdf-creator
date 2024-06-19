# frozen_string_literal: true

require 'erb'
require 'json'
require 'optparse'
require 'commonmarker'
require 'puppeteer-ruby'

def make_invoice_model(data)
  format_currency = ->(amount) { ((amount * 100).round / 100).to_s }

  items = data['items'].map do |item|
    { **item, total: item['hours'] * item['rate'] }
  end

  totals = data['items'].map do |item|
    item['hours'] * item['rate']
  end

  sub_total = totals.sum
  gst = sub_total * 0.1
  total = data['gst_included'] ? sub_total : sub_total * 1.1

  {
    me: {
      name: data['me']['name'],
      addr_line1: data['me']['addrLine1'],
      addr_line2: data['me']['addrLine2'],
      country: data['me']['country'],
      abn: data['me']['abn']
    },
    client: {
      name: data['client']['name'],
      phone: data['client']['phone'],
      abn: data['client']['abn']
    },
    invoice_no: data['invoiceNo'],
    date: data['date'],
    items: items.map do |item|
             {
               name: item['name'],
               hours: item['hours'],
               rate: item['rate'],
               total: format_currency.call(item[:total])
             }
           end,
    payment: {
      name: data['payment']['name'],
      bsb: data['payment']['bsb'],
      account_no: data['payment']['accountNo']
    },
    sub_total: format_currency.call(sub_total),
    gst: data['gst_included'] == true ? 'Included' : format_currency.call(gst),
    total: format_currency.call(total)
  }
end

def invoice_html(config_path)
  raw = JSON.parse(File.read(config_path))
  model = make_invoice_model(raw)

  ERB.new(File.read('lib/invoice.erb')).result_with_hash(model)
end

def md_html(file_path)
  raw = File.read(file_path)

  # UNSAFE allows raw HTML which allows styling by embedding <style> tags in the markdown
  CommonMarker.render_html(raw, %i[HARDBREAKS UNSAFE])
end

def to_pdf(html, out)
  buffer = Puppeteer.launch do |browser|
    page = browser.new_page
    page.set_content(html)
    page.pdf(transferMode: 'ReturnAsStream')
  end

  File.binwrite(out, buffer)
end

if __FILE__ == $0
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: mkinvoice --config | --md [OPTIONS]'
    opts.on('-c', '--config=CONFIG', 'configuration file')
    opts.on('-m', '--md=MD', 'markdown file')
    opts.on('-o', '--out=OUT', 'output file')
  end

  options = {}
  parser.parse!(into: options)

  unless options[:config] || options[:md]
    puts('Missing required option --config or --md')
    exit 1
  end

  unless File.exist?(options[:config])
    puts("No such file: #{options[:config]}")
    exit 1
  end

  html =
    if options[:config]
      invoice_html(options[:config])
    elsif options[:md]
      md_html(options[:md])
    end

  to_pdf(html, options[:out] || 'out.pdf')
end

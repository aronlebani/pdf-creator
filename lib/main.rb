# frozen_string_literal: true

require 'erb'
require 'tomlrb'
require 'optparse'
require 'commonmarker'
require 'puppeteer-ruby'

CURRENCY = 'AUD'
TAX_RATE = 0.1

def format_currency(amount)
  sprintf('%.2f', amount)
end

def make_invoice_model(data)
  items = data[:items].map { |i| { **i, total: i[:hours] * i[:rate] } }
  sub_total = data[:items].reduce(0) { |sum, i| sum + i[:hours] * i[:rate] }
  gst = sub_total * TAX_RATE
  total = data[:gstinclusive] ? sub_total : sub_total + gst

  {
    **data,
    items: items.map do |i|
      {
        **i,
        rate: format_currency(i[:rate]),
        total: format_currency(i[:total]),
      }
    end,
    subtotal: format_currency(sub_total),
    gst: data[:gstinclusive] == true ? 'Included' : format_currency(gst),
    total: format_currency(total),
    currency: CURRENCY,
  }
end

def invoice_html(config_path)
  raw = Tomlrb.parse(File.read(config_path), symbolize_keys: true)
  model = make_invoice_model(raw)

  ERB.new(File.read('lib/invoice.erb')).result_with_hash(model)
end

def md_html(file_path)
  raw = File.read(file_path)

  # UNSAFE allows raw HTML which allows styling by embedding <style> tags in
  # the markdown
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

  html = if options[:config]
    invoice_html(options[:config])
  elsif options[:md]
    md_html(options[:md])
  end

  to_pdf(html, options[:out] || 'out.pdf')
end

# frozen_string_literal: true

require 'erb'
require 'tomlrb'
require 'optparse'
require 'commonmarker'
require 'puppeteer-ruby'

CURRENCY = 'AUD'
TAX_RATE = 0.1

def format_currency(amount)
  sprintf '%.2f', amount
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
        total: format_currency( i[:total]),
      }
    end,
    subtotal: format_currency(sub_total),
    gst: data[:gstinclusive] == true ? 'Included' : format_currency(gst),
    total: format_currency(total),
    currency: CURRENCY,
  }
end

def invoice_html(config_path)
  raw = File.read config_path
  toml = Tomlrb.parse raw, symbolize_keys: true
  model = make_invoice_model toml

  erb = ERB.new File.read 'lib/invoice.erb'
  erb.result_with_hash model
end

def md_html(file_path)
  raw = File.read file_path

  # UNSAFE allows raw HTML which allows styling by embedding <style> tags in
  # the markdown
  CommonMarker.render_html raw, %i[HARDBREAKS UNSAFE]
end

def to_pdf(html, out)
  buffer = Puppeteer.launch do |browser|
    page = browser.new_page
    page.set_content html
    page.pdf transferMode: 'ReturnAsStream'
  end

  File.binwrite out, buffer
end

def main(args)
  html = if args[:config]
    invoice_html args[:config]
  elsif args[:md]
    md_html args[:md]
  end

  to_pdf html, args[:out] || 'out.pdf'
end

if __FILE__ == $0
  args = {}
  parser = OptionParser.new

  parser.banner = 'Usage: mkinvoice --config | --md [OPTIONS]'
  parser.on '-c', '--config=CONFIG', 'configuration file'
  parser.on '-m', '--md=MD', 'markdown file'
  parser.on '-o', '--out=OUT', 'output file'

  parser.parse! into: args

  unless args[:config] || args[:md]
    puts 'Missing required option --config or --md'
    exit 1
  end

  unless File.exist? args[:config]
    puts "No such file: #{args[:config]}"
    exit 1
  end

  main args
end

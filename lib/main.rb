# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'optparse'
require 'commonmarker'
require 'puppeteer-ruby'

module Markdown
  def to_html(file_path)
    raw = File.read file_path

    # UNSAFE allows raw HTML which allows styling by embedding <style> tags in the markdown
    CommonMarker.render_html raw, %i[HARDBREAKS UNSAFE]
  end
end

module Pdf
  def generate(url)
    Puppeteer.launch do |browser|
      page = browser.new_page
      page.goto(url)
      page.pdf transferMode: 'ReturnAsStream'
    end
  end
end

module Invoice
  def format_currency(amount)
    ((amount * 100).round / 100).to_s
  end

  def create_model(config_path)
    raw = File.read config_path
    data = JSON.parse raw

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
                 total: (format_currency item[:total])
               }
             end,
      payment: {
        name: data['payment']['name'],
        bsb: data['payment']['bsb'],
        account_no: data['payment']['accountNo']
      },
      sub_total: (format_currency sub_total),
      gst: data['gst_included'] == true ? 'Included' : (format_currency gst),
      total: (format_currency total)
    }
  end
end

include Markdown
include Invoice
include Pdf

get '/' do
  Markdown.to_html './README.md'
end

get '/invoice/_' do
  config_path = params['config']
  model = Invoice.create_model config_path

  erb :invoice, locals: model
end

get '/invoice' do
  config_path = params['config']
  buffer = Pdf.generate "http://localhost:4567/invoice/_?config=#{config_path}"

  [200, { 'Content-Type' => 'application/pdf' }, buffer]
end

get '/markdown/_' do
  md_path = params['md']
  Markdown.to_html md_path
end

get '/markdown' do
  md_path = params['md']
  buffer = Pdf.generate "http://localhost:4567/markdown/_?md=#{md_path}"

  [200, { 'Content-Type' => 'application/pdf' }, buffer]
end

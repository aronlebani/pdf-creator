# frozen_string_literal: true

require "sinatra"
require "optparse"

require_relative "invoice"
require_relative "markdown"
require_relative "pdf"

include Invoice
include Markdown
include Pdf

get "/invoice/_" do
  config_path = params["config"]
  model = Invoice.create_model config_path

  erb :invoice, locals: model
end

get "/invoice" do
  config_path = params["config"]
  buffer = Pdf.generate "http://localhost:4567/invoice/_?config=#{config_path}"

  [200, { "Content-Type" => "application/pdf" }, buffer]
end

get "/markdown/_" do
  md_path = params["md"]
  Markdown.to_html md_path
end

get "/markdown" do
  md_path = params["md"]
  buffer = Pdf.generate "http://localhost:4567/markdown/_?md=#{md_path}"

  [200, { "Content-Type" => "application/pdf" }, buffer]
end

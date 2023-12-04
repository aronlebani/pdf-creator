# frozen_string_literal: true

require "json"

module Invoice
  def format_currency(amount)
    ((amount * 100).round / 100).to_s
  end

  def create_model(config_path)
    raw = File.read config_path
    data = JSON.parse raw

    items = data["items"].map do |item|
      { **item, total: item["hours"] * item["rate"] }
    end

    totals = data["items"].map do |item|
      item["hours"] * item["rate"]
    end

    sub_total = totals.sum
    gst = sub_total * 0.1
    total = data["gst_included"] ? sub_total : sub_total * 1.1

    {
      me: {
        name: data["me"]["name"],
        addr_line1: data["me"]["addrLine1"],
        addr_line2: data["me"]["addrLine2"],
        country: data["me"]["country"],
        abn: data["me"]["abn"]
      },
      client: {
        name: data["client"]["name"],
        phone: data["client"]["phone"],
        abn: data["client"]["abn"]
      },
      invoice_no: data["invoiceNo"],
      date: data["date"],
      items: items.map do |item|
               {
                 name: item["name"],
                 hours: item["hours"],
                 rate: item["rate"],
                 total: (format_currency item[:total])
               }
             end,
      payment: {
        name: data["payment"]["name"],
        bsb: data["payment"]["bsb"],
        account_no: data["payment"]["accountNo"]
      },
      sub_total: (format_currency sub_total),
      gst: data["gst_included"] == true ? "Included" : (format_currency gst),
      total: (format_currency total)
    }
  end
end

require "puppeteer-ruby"

module Pdf
    def generate url
        Puppeteer.launch do |browser|
            page = browser.new_page
            page.goto(url)
            page.pdf transferMode: "ReturnAsStream"
        end
    end
end

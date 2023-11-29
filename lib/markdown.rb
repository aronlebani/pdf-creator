require "commonmarker"

module Markdown
    def to_html file_path 
        raw = File.read file_path

        # UNSAFE allows raw HTML which allows styling by embedding <style> tags in the markdown
        CommonMarker.render_html raw, [:HARDBREAKS, :UNSAFE]
    end
end

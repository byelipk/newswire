class TextCleaner
  def self.clean(res, options)
    doc = Nokogiri::HTML(res)

    # Clean up the html doc to save bytes
    puts "Cleaning html doc..."

    body = doc.css(options[:css])
    body.css('script').remove
    body.css('noscript').remove
    body.css('iframe').remove
    body.css('form').remove
    body.css('svg').remove
    body.css('video').remove
    body.css('img').remove
    body.css('canvas').remove

    # Remove excessive spacing
    body.text.gsub(/\s\s+/, '')
  end
end

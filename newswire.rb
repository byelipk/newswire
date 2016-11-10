require 'net/http'
require 'uri'
require 'csv'
require 'nokogiri'
require 'pry'
require 'optparse'
require 'fast_blank'
require 'xor'
require 'fast_xs'

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: --url=https://www.url.com/articles/1 --slant=0i"

  opts.on("-i", "--init", "Start over with a new data file.") do |v|
    options[:init] = v
  end

  opts.on("-f", "--file=FILE", "Name of data file.") do |v|
    options[:file] = v
  end

  opts.on("-h", "--url=URL", "The URL to fetch the article from.") do |v|
    options[:url] = v
  end

  opts.on("-s", "--slant=VALUE", "Tag the political slant of the article. (-1 left, 0 null, 1 right)") do |v|
    options[:slant] = v
  end

  opts.on("-l", "--selector=SELECTOR", "CSS selector for the content.") do |v|
    options[:selector] = v
  end
end

parser.parse!

# Make sure we have a file to save data to.
unless options[:file]
  puts "Using default filename..."
  options[:file] = "db.csv"
end

# Are we reinitializing the project?
if options[:init]
  puts "Setting up new project..."
  `rm -f #{options[:file]}`

  CSV.open(options[:file], "w") do |row|
    row << ["URL", "html", "slant"]
  end

  exit(1)
end

# Do we have a url to fetch?
unless options[:url]
  puts "Using default URL..."
  options[:url] = "https://www.good.is/articles/moore-five-point-plan"
end

# Do we have a political slant?
unless options[:slant]
  puts "Using default political slant..."
  options[:slant] = 0
end

puts "Making request to #{options[:url]}..."

uri = URI.parse(options[:url])
res = Net::HTTP.get(uri)
doc = Nokogiri::HTML(res)

puts "Cleaning html doc..."

if options[:selector]
  body = doc.css(options[:selector])
else
  # Just remove as much crap as we can to save bytes
  body = doc.css('body')
  body.css('script').remove
  body.css('noscript').remove
  body.css('iframe').remove
  body.css('form').remove
  body.css('svg').remove
end

# Remove excessive spacing
text = body.text.gsub(/\s\s+/, '')

puts "Appending data to #{options[:file]}..."
CSV.open(options[:file], "a+") do |row|
  row << [ options[:url], text, options[:slant] ]
end

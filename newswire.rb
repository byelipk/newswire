require 'net/http'
require 'uri'
require 'csv'
require 'nokogiri'
require 'pry'
require 'fast_blank'
require 'xor'
require 'fast_xs'
require 'yaml'
require 'json'

require_relative 'cli_parser'


options = CLIParser.new(ARGV).parse!

# Are we reinitializing the project?
if options[:init]
  puts "Setting up new project..."

  `rm -f #{options[:file]}`

  CSV.open(options[:file], "w") do |row|
    row << ["URL", "html", "slant"]
  end

  exit(1)
end

unless options[:url]
  raise ArgumentError,
    "Must supply a valid url so we can fetch an article."
end

puts "Making request to #{options[:url]}..."

uri = URI.parse(options[:url])
res = Net::HTTP.get(uri)
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
text = body.text.gsub(/\s\s+/, '')

# repo_options = YAML.load(File.read("./repo.yml"))
# repo = JSON.parse(
#   Net::HTTP.get(
#     URI.parse(repo_options["repo_url"])))


puts "Appending data to #{options[:file]}..."
CSV.open(options[:file], "a+") do |row|
  row << [ options[:url], text, options[:slant] ]
end

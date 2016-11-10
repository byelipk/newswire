require 'csv'
require 'nokogiri'
require 'pry'
require 'fast_blank'
require 'xor'
require 'fast_xs'
require 'base64'

require_relative 'cli_parser'
require_relative 'repo'
require_relative 'text_cleaner'


# Get any default options we have
REPO_OPTS = YAML.load(File.read("./repo.yml"))

# Parse options we pass through the command line
parser    = CLIParser.new(ARGV, file: REPO_OPTS[:file])
options   = parser.parse!

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

# Fetch the political article and process it so we have the
# raw text of the html page, minus things like script, img, etc...
puts "Making request to #{options[:url]}..."

res  = Repo.fetch_article(options[:url])
text = TextCleaner.clean(res, options)

# Now that we have the raw text we can pull the current data set from github
puts "Fetching current repository..."

curr = Repo.fetch_repo(REPO_OPTS['db_url'])

# Transform db into an array of arrays
db = CSV.parse(Base64.decode64(curr["content"]))

# Append new data to csv file
db.push([ options[:url], text, options[:slant]])

# Required data fields
domain  = URI.parse(options[:url]).host.gsub(/^w{3}\./, '')
res     = Repo.update_repo(
  REPO_OPTS['db_url'],
  path: curr['path'],
  message: "New data from #{domain}",
  content: Base64.encode64(db.to_s),
  sha: curr['sha']
)

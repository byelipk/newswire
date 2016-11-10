require 'optparse'

class CLIParser

  DEFAULT_DATA_FILE = 'db.csv'
  DEFAULT_POLITICAL_SLANT = 0

  attr_reader :options, :parser, :args

  def initialize(args, options = Hash.new)
    @args    = args
    @options = {
      init:  false,
      file:  options[:file] || DEFAULT_DATA_FILE,
      url:   false,
      slant: DEFAULT_POLITICAL_SLANT,
      css:   'body'
    }
  end

  def parse!
    parser.parse!(args)
    options
  end

  def parser
    @parser ||= OptionParser.new do |opts|
      opts.banner = "Usage: --url=https://www.url.com/articles/1 --slant=0i"

      opts.on("--init", "Start over with a new data file.") do |v|
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

      opts.on("-css", "--css=SELECTOR", "CSS selector for title content.") do |v|
        options[:css_selector] = v
      end
    end
  end
end

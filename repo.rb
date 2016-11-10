require 'net/http'
require 'uri'
require 'csv'
require 'yaml'
require 'json'

class Repo
  def self.fetch_article(url)
    Net::HTTP.get(
      URI.parse(url))
  end

  def self.fetch_repo(url)
    JSON.parse(
      Net::HTTP.get(
        URI.parse(url)))
  end

  def self.update_repo(url, options = Hash.new)
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    binding.pry
    request = Net::HTTP::Put.new(uri)
    request.set_form_data(options)
    response = http.request(request)

    puts response.body
  end
end

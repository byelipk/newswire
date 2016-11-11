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

  def self.update_repo(url, api_token, options = Hash.new)
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Put.new(uri)
    request.add_field("Authorization", "token #{api_token}")
    request.body = options.to_json
    response = http.request(request)

    puts response.body
  end
end

require 'sinatra'
require "sinatra/reloader" if development?
require 'net/http'

get '/' do 
  "Hello World!"
end


uri = URI('https://getpocket.com/v3/oauth/request')
req = Net::HTTP::Post.new(uri)
req.set_form_data('consumer_key' => '38764-22db1d3236e8c5775086509d', 'redirect_uri' => 'http://localhost:4567')

res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  http.request(req)
end

case res

when Net::HTTPSuccess, Net::HTTPRedirection
  puts res.code
  puts res.message
  puts res.class.name
  puts res.body
else
  res.value
end

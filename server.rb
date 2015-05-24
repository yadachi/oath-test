require 'sinatra'
require "sinatra/reloader" if development?
require 'net/http'
require 'json'

configure do 
  enable :sessions
end

get '/' do 
  '<a href="/connect">Hello world! connect to pocket</a>'
end

get '/connect' do 
uri = URI('https://getpocket.com/v3/oauth/request')
req = Net::HTTP::Post.new(uri)
req.set_form_data('consumer_key' => '38764-22db1d3236e8c5775086509d', 'redirect_uri' => 'http://localhost:4567/oauth')

res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  http.request(req)
end
result = Hash[URI.decode_www_form(res.body)]
session[:code] = result['code'] 

CALLBACK = 'http://localhost:4567/oauth'
redirect_uri = "https://getpocket.com/auth/authorize?request_token=" + session[:code] + "&redirect_uri=" + CALLBACK
puts redirect_uri
puts session[:code]
redirect redirect_uri
end

get '/oauth' do 
auth_uri = URI('https://getpocket.com/v3/oauth/authorize')
auth_req = Net::HTTP::Post.new(auth_uri)
auth_req.set_form_data('consumer_key' => '38764-22db1d3236e8c5775086509d', 'code' => session[:code] )
puts session[:code]
puts auth_req
puts auth_req.body
auth_res = Net::HTTP.start(auth_uri.hostname, auth_uri.port, :use_ssl => auth_uri.scheme == 'https') do |http|
  http.request(auth_req)
end
puts  "auth_body #{auth_res.body}"
auth_result = Hash[URI.decode_www_form(auth_res.body)]
puts "auth_result: #{auth_result}"
session[:access_token] = auth_result['access_token']
puts "session: #{session[:access_token]}"
"#{session[:access_token]}"
redirect '/list'
end

get '/list' do
retrieve_uri = URI('https://getpocket.com/v3/get')
retrieve_req = Net::HTTP::Post.new(retrieve_uri, 'Content-Type' => 'application/json')
retrieve_req.body = {
  'consumer_key' => '38764-22db1d3236e8c5775086509d',
  'access_token' => session[:access_token],
  'state' => 'unread',
  'contentType' => 'article'
  }.to_json

retrieve_res = Net::HTTP.start(retrieve_uri.hostname, retrieve_uri.port, :use_ssl => retrieve_uri.scheme == 'https') do |http|
  http.request(retrieve_req)
end
"#{retrieve_res.body}"

end


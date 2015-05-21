require 'sinatra'
require "sinatra/reloader" if development?
require 'net/http'

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
puts  auth_res.body
"#{auth_res.body}"

#"#{code}"
#"<pre>#{res.class.name}</pre>"
#"<pre>#{res.body}</pre>"


#case res


#when Net::HTTPSuccess, Net::HTTPRedirection
#  "<pre>#{res.code}</pre>"
#  puts res.message
#  puts res.class.name
#  puts res.body
#else
#  res.value
#end
end

require 'sinatra'
require 'sinatra/reloader'
#sinatra-contrib installed so server doesn't need to restart constantly

get '/' do
  "Hello, World!"
end

get '/about' do
  'A little about me.'
end

get '/hello/:name/:city' do
  # params [:name]
  "Hello there, #{params[:name].capitalize} from #{params[:city].capitalize}."  
end

get '/more/*' do
  "#{params[:splat]}"
end

get '/form' do
  erb :form
end

post '/form' do
  "You said '#{params[:message]}'"
end

get '/secret' do
  erb :secret
end

post '/secret' do
  params[:secretpost].reverse
end

get '/decrypt/:secret' do
  params[:secret].reverse
end

# not_found do
#   status 404
#   'not found'
# end


not_found do
  halt 404, "not found dude"
end


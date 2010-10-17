require 'rubygems'
require 'sinatra'
require 'skgt'
require 'json'

get'/' do
    redirect '/main.html'
end

get '/times/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    times = skgt.get_times(
        params[:ttype],
        params[:line],
        params[:route],
        params[:stop]
    )

    JSON.dump(times)
end

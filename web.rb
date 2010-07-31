require 'rubygems'
require 'sinatra'
require 'skgt'
require 'json'


get '/initial_data/' do
    content_type 'text/json', :charset => 'utf-8'
    (File.open 'initial_data').read
end
    

get'/' do
    redirect '/main.html'
end

get '/times/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    times = skgt.get_times params[:ttype], params[:line], params[:route], params[:stop]

    times = times.map do |time|
        time[0...5]
    end

    JSON.dump(times)
end

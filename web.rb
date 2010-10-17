require 'rubygems'
require 'sinatra'
require 'skgt'
require 'json'


# get '/initial_data/' do
#     content_type 'text/json', :charset => 'utf-8'
#     expires 60 * 60 * 24 * 365, :public
#     (File.open 'initial_data').read
# end
# 

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

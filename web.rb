require 'sinatra'
require 'skgt'
require 'json'

enable :sessions

get '/lines/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    lines = skgt.get_lines params[:ttype]

    #skgt.save(session)

    JSON.dump(lines)
end

get '/routes/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    lines = skgt.get_lines params[:ttype]
    routes = skgt.get_routes params[:ttype], params[:line]

    JSON.dump(routes)
end

get '/stops/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    lines = skgt.get_lines params[:ttype]
    routes = skgt.get_routes params[:ttype], params[:line]
    stops = skgt.get_stops params[:ttype], params[:line], params[:route]

    JSON.dump(stops)
end

get '/times/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    lines = skgt.get_lines params[:ttype]
    routes = skgt.get_routes params[:ttype], params[:line]
    stops = skgt.get_stops params[:ttype], params[:line], params[:route]
    times = skgt.get_times params[:ttype], params[:line], params[:route], params[:stop]

    times = times.map do |time|
        time[0...5]
    end

    JSON.dump(times)
end

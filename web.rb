require 'sinatra'
require 'skgt'
require 'json'

get '/lines/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    lines = skgt.get_lines params[:ttype]

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

    JSON.dump(times)
end

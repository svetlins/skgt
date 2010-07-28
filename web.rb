require 'rubygems'
require 'sinatra'
require 'skgt'
require 'json'

get '/cache/' do
    content_type 'text/json', :charset => 'utf-8'
    (File.open 'cache').read
end
    

get'/' do
    redirect '/main.html'
end

get '/lines/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    lines = skgt.get_lines params[:ttype]

    JSON.dump(lines)
end

get '/routes/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    routes = skgt.get_routes params[:ttype], params[:line]

    JSON.dump(routes)
end

get '/stops/' do
    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    stops = skgt.get_stops params[:ttype], params[:line], params[:route]

    JSON.dump(stops)
end

get '/times/' do
    # for testing purposes
    # return JSON.dump((0..7).map { |x| '22:%02d' % (5 * x) })

    content_type 'text/json', :charset => 'utf-8'
    skgt = Skgt::SKGTHandler.new
    times = skgt.get_times params[:ttype], params[:line], params[:route], params[:stop]

    times = times.map do |time|
        time[0...5]
    end

    JSON.dump(times)

end

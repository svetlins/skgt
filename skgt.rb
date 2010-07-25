require 'net/http'
require 'nokogiri'

module Skgt

SKGT_ADDR = URI.parse 'http://gps.skgt-bg.com/Web/SelectByLine.aspx'

class SKGTHandler
    def initialize
        get_initial_state()
    end

    @@sequence = [
        :get_lines,
        :get_routes,
        :get_stops,
        :get_times,
    ]

    def method_missing method, *arguments, &block
        if @@sequence.member? method
            current_index = 0
            method_index = @@sequence.index method


            while method_index != current_index do
                send @@sequence[current_index], *arguments[0..current_index]
                current_index += 1
            end

            send method, *arguments
        else
            raise NoMethodError, method
        end
    end

    private

    def get_initial_state
        Net::HTTP.start(SKGT_ADDR.host, SKGT_ADDR.port) do |http|
            response = http.get(SKGT_ADDR.path)
            page = Nokogiri::HTML response.body

            get_state page
        end
    end

    def get_state page
        @vs = page.xpath("//input[@name='__VIEWSTATE']").attribute('value').to_s
        @ev = page.xpath("//input[@name='__EVENTVALIDATION']").attribute('value').to_s
    end

    def post data
        page = nil
        Net::HTTP.start(SKGT_ADDR.host, SKGT_ADDR.port) do |http|
            request = Net::HTTP::Post.new SKGT_ADDR.path
            request.set_form_data data

            response = http.request request

            page = Nokogiri::HTML response.body, nil, 'UTF-8'

            get_state page
        end

        return page
    end


    def get_lines transport_type

        page = post '__VIEWSTATE' => @vs,
                    '__EVENTVALIDATION' => @ev,
                    'ctl00$ScriptManager1' => 'ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$ddlTransportType',
                    '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$ddlTransportType',
                    '__EVENTARGUMENT' => '',
                    '__LASTFOCUS' => '',
                    'ctl00$ContentPlaceHolder1$ddlTransportType' => transport_type,
                    'ctl00$ContentPlaceHolder1$ddlLines' => '',
                    'ctl00$ContentPlaceHolder1$ddlStops' => ''


        lines = page.xpath('//select[@name=\'ctl00$ContentPlaceHolder1$ddlLines\']/option').map do |option|
            [
             option.children.to_s,
             option.attribute('value').to_s
            ] if option.attribute('value').to_s.length > 0
        end

        return lines.compact
    end

    def get_routes transport_type, line_id
        page = post '__VIEWSTATE' => @vs,
                    '__EVENTVALIDATION' => @ev,
                    'ctl00$ScriptManager1' => 'ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$ddlLines',
                    '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$ddlLines',
                    '__EVENTARGUMENT' => '',
                    '__LASTFOCUS' => '',
                    'ctl00$ContentPlaceHolder1$ddlTransportType' => transport_type,
                    'ctl00$ContentPlaceHolder1$ddlLines' => line_id,
                    'ctl00$ContentPlaceHolder1$ddlStops' => ''

        route0 = page.xpath('//input[@id=\'ctl00_ContentPlaceHolder1_rblRoute_0\']')
        route1 = page.xpath('//input[@id=\'ctl00_ContentPlaceHolder1_rblRoute_1\']')

        routes = []

        routes = ([route0, route1]).map do |route| 
            [
             route.xpath('following-sibling::label[position()=1]').children.to_s,
             route.attribute('value').to_s
            ]
        end

        return routes.compact
    end

    def get_stops transport_type, line_id, route_id

        page = post '__VIEWSTATE' => @vs,
                    '__EVENTVALIDATION' => @ev,
                    'ctl00$ScriptManager1' => 'ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$rblRoute$0',
                    '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$rblRoute$0',
                    '__EVENTARGUMENT' => '',
                    '__LASTFOCUS' => '',
                    'ctl00$ContentPlaceHolder1$ddlTransportType' => transport_type,
                    'ctl00$ContentPlaceHolder1$ddlLines' => line_id,
                    'ctl00$ContentPlaceHolder1$rblRoute' => route_id,
                    'ctl00$ContentPlaceHolder1$ddlStops' => ''

        stops = page.xpath('//select[@name=\'ctl00$ContentPlaceHolder1$ddlStops\']/option').map do |option|
            [
                option.children.to_s, option.attribute('value').to_s
            ] if option.attribute('value').to_s.length > 0
        end

        return stops.compact
    end

    def get_times transport_type, line_id, route_id, stop_id

        page = post '__VIEWSTATE' => @vs,
                    '__EVENTVALIDATION' => @ev,
                    'ctl00$ScriptManager1' => 'ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$ddlStops',
                    '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$ddlStops',
                    '__EVENTARGUMENT' => '',
                    '__LASTFOCUS' => '',
                    'ctl00$ContentPlaceHolder1$ddlTransportType' => transport_type,
                    'ctl00$ContentPlaceHolder1$ddlLines' => line_id,
                    'ctl00$ContentPlaceHolder1$rblRoute' => route_id,
                    'ctl00$ContentPlaceHolder1$ddlStops' => stop_id

        times = page.xpath('//table[@id=\'ctl00_ContentPlaceHolder1_gvTimes\']//span').map do |span|
            span.children.to_s
        end

        return times.compact
    end

end

end

skgt = Skgt::SKGTHandler.new

#lines = skgt.get_lines 1
#p lines
#
#routes = skgt.get_routes 1, lines[50][1]
#p routes[0][0]
#
#stops = skgt.get_stops 1, lines[50][1], routes[0][1]
#p stops
#
#p 1, lines[50][1], routes[0][1], stops[5][1] 
#p skgt.get_times 1, '54', "1076", "16899"

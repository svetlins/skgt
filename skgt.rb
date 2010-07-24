require 'net/http'
require 'nokogiri'

SKGT = URI.parse 'http://gps.skgt-bg.com/Web/SelectByLine.aspx'

TRANSPORT_TYPE = 1 # by bus

def get_junk page

    viewstate = page.xpath "//input[@name='__VIEWSTATE']"
    ev_validation = page.xpath "//input[@name='__EVENTVALIDATION']"

    return viewstate.attribute('value').to_s, ev_validation.attribute('value').to_s
end

def get_initial
    viewstate = nil
    ev_validation = nil

    Net::HTTP.start(SKGT.host, SKGT.port) do |http|
        response = http.get(SKGT.path)
        page = Nokogiri::HTML response.body

        viewstate, ev_validation = get_junk page
    end

    return viewstate, ev_validation
end

def get_lines viewstate, ev_validation, transport_type

    lines = {}
    vs = nil
    ev = nil

    Net::HTTP.start(SKGT.host, SKGT.port) do |http|
        request = Net::HTTP::Post.new SKGT.path
        request.set_form_data '__VIEWSTATE' => viewstate,
            '__EVENTVALIDATION' => ev_validation,
            'ctl00$ScriptManager1' => 'ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$ddlTransportType',
            '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$ddlTransportType',
            '__EVENTARGUMENT' => '',
            '__LASTFOCUS' => '',
            'ctl00$ContentPlaceHolder1$ddlTransportType' => transport_type,
            'ctl00$ContentPlaceHolder1$ddlLines' => '',
            'ctl00$ContentPlaceHolder1$ddlStops' => ''

        response = Net::HTTP.new(SKGT.host, SKGT.port).start do |http|
            http.request request
        end

        page = Nokogiri::HTML response.body

        vs, ev = get_junk page

        page.xpath('//select[@name=\'ctl00$ContentPlaceHolder1$ddlLines\']/option').each do |option|
            
            lines[option.children.to_s] = option.attribute('value').to_s if option.attribute('value').to_s.length > 0
        end
    end

    return vs, ev, lines
end

def get_routes viewstate, ev_validation, transport_type, line_id

    routes = []
    vs, ev = nil, nil

    Net::HTTP.start(SKGT.host, SKGT.port) do |http|
        request = Net::HTTP::Post.new SKGT.path
        request.set_form_data '__VIEWSTATE' => viewstate,
            '__EVENTVALIDATION' => ev_validation,
            'ctl00$ScriptManager1' => 'ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$ddlLines',
            '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$ddlLines',
            '__EVENTARGUMENT' => '',
            '__LASTFOCUS' => '',
            'ctl00$ContentPlaceHolder1$ddlTransportType' => transport_type,
            'ctl00$ContentPlaceHolder1$ddlLines' => line_id,
            'ctl00$ContentPlaceHolder1$ddlStops' => ''

        response = Net::HTTP.new(SKGT.host, SKGT.port).start do |http|
            http.request request
        end

        page = Nokogiri::HTML response.body

        vs, ev = get_junk page

        route0 = page.xpath('//input[@id=\'ctl00_ContentPlaceHolder1_rblRoute_0\']')
        route1 = page.xpath('//input[@id=\'ctl00_ContentPlaceHolder1_rblRoute_1\']')

        routes = ([route0, route1]).map do |route| 
            [
             route.xpath('following-sibling::label[position()=1]').children.to_s,
             route.attribute('value').to_s
            ]
        end

    end

    puts routes

    return vs, ev, routes
end



vs, ev_validation = get_initial
vs, ev_validation, lines = get_lines vs, ev_validation, TRANSPORT_TYPE
puts get_routes vs, ev_validation, 1, 66

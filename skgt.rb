require 'rubygems'
require 'nokogiri'
require 'net/http'

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

    def get_state
      [@vs, @ev]
    end

    def set_state state
      @vs, @ev = state
    end


    private

    def get_initial_state
      Net::HTTP.start(SKGT_ADDR.host, SKGT_ADDR.port) do |http|

        headers = {
          'User-Agent' => 'Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.12 (KHTML, like Gecko) Ubuntu/10.04 Chromium/9.0.579.0 Chrome/9.0.579.0 Safari/534.12'
        }
        response = http.get(SKGT_ADDR.path, headers)
        page = Nokogiri::HTML response.body

        read_state page
      end
    end

    def read_state page
      @vs = page.xpath("//input[@name='__VIEWSTATE']").attribute('value').to_s
      @ev = page.xpath("//input[@name='__EVENTVALIDATION']").attribute('value').to_s
    end

    def post data
      page = Net::HTTP.start(SKGT_ADDR.host, SKGT_ADDR.port) do |http|
        request = Net::HTTP::Post.new SKGT_ADDR.path
        request.set_form_data data

        response = http.request request

        page = Nokogiri::HTML response.body, nil, 'UTF-8'

        read_state page

        page
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

      # temp
      #@stops = stops.compact
      
      return stops.compact
    end

    def get_times transport_type, line_id, route_id, stop_id

      #stops_ctl = {}
      #@stops.each_with_index do |stop, index|
      #  ctl = index + 2
      #  stops_ctl[
      #    'ctl00$ContentPlaceHolder1$gvRoute$ctl' + ctl.to_s.rjust(2, '0') + '$hfStopID'
      #  ] = stop[1]
      #end

      post_data = {
        '__VIEWSTATE' => @vs,
        '__EVENTVALIDATION' => @ev,
        'ctl00$ScriptManager1' => 'ctl00$ContentPlaceHolder1$upMain|ctl00$ContentPlaceHolder1$ddlStops',
        '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$ddlStops',
        '__EVENTARGUMENT' => '',
        '__LASTFOCUS' => '',
        'ctl00$ContentPlaceHolder1$ddlTransportType' => transport_type,
        'ctl00$ContentPlaceHolder1$ddlLines' => line_id,
        'ctl00$ContentPlaceHolder1$rblRoute' => route_id,
        'ctl00$ContentPlaceHolder1$ddlStops' => stop_id
      }

      #post_data.merge! stops_ctl

      page = post post_data

      times = page.xpath('//table[@id=\'ctl00_ContentPlaceHolder1_gvTimes\']//div').map do |span|
        span.children.to_s
      end

      return times.compact.map do |time|
        time[0...5]
      end

    end

  end


  def self.build_cache
    init = [
      ['bus', 1],
      ['tram', 0],
      ['trol', 2]
    ]

    cache = {}

    skgt = SKGTHandler.new

    init.each do |type_name, type_id|
      state = skgt.get_state

      (skgt.get_lines type_id).each do |line_name, line_id|
        state = skgt.get_state

        (skgt.get_routes type_id, line_id).each do |route_name, route_id|
          state = skgt.get_state

          cache[type_id] ||= {'name' => type_name, 'lines' => {}}
          cache[type_id]['lines'][line_id] ||= {'name' => line_name, 'routes' => {}}
          cache[type_id]['lines'][line_id]['routes'][route_id] ||= {'name' => route_name, 'stops' => []}

          cache[type_id]['lines'][line_id]['routes'][route_id]['stops'] = skgt.get_stops type_id, line_id, route_id

          skgt.set_state state
        end
        skgt.set_state state
      end
      skgt.set_state state
    end

    cache
  end

end

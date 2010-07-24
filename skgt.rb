require 'net/http'
require 'nokogiri'

SKGT = URI.parse 'http://gps.skgt-bg.com/Web/SelectByLine.aspx'

def get_some_info
    Net::HTTP.start(SKGT.host, SKGT.port) do |http|
        page_html = http.get(SKGT.path)

        page = Nokogiri::HTML page_html.body

        viewstate = page.xpath "//input[@name='__VIEWSTATE']"
        ev_validation = page.xpath "//input[@name='__EVENTVALIDATION']"

        puts viewstate.attribute 'value'
        puts
        puts ev_validation.attribute 'value'
    end
end

get_some_info

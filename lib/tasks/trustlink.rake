require 'nokogiri'
require 'open-uri'

namespace :trustlink do
  def say text
    if Rails.env.development?
      puts text
    end
  end

  desc "Fetch links from server"
  task fetch: :environment do
    begin
      config = YAML.load_file('config/trustlink.yml') 
    rescue Errno::ENOENT
      fail "Config file not found (config/trustlink.yml)"
    end

    key      = config['key']
    domain   = config['domain'].downcase
    encoding = config['encoding'].upcase || 'UTF-8'
    server   = config['server']          || 'db.trustlink.ru'

    url = "http://#{server}/#{key}/#{domain}/#{encoding}.xml"
    begin
      data = open(url)
    rescue OpenURI::HTTPError
      fail "Could not receive data"
    end

    root = Nokogiri::XML(data.read).root

    bot_ips = root.xpath('bot_ips/ip')
    configs = root.xpath('config/item')
    pages   = root.xpath('pages/page')

    if pages.any?
      TrustlinkConfig.delete_all
      TrustlinkLink.delete_all

      say "Ips:"
      bot_ips.each do |ip|
        TrustlinkConfig.create name: 'ip', value: ip.text
        say "Added #{ip.text}"
      end

      say "Config"
      configs.each do |item|
        TrustlinkConfig.create name: item['name'], value: item.text
        say "Added #{item['name']} = #{item.text}"
      end

      say "Links"
      pages.each do |page|
        say "Page: #{page['url']}"
        page.xpath('link').each do |item|
          anchor = item.at_xpath('anchor').text
          text   = item.at_xpath('text').text
          url    = item.at_xpath('url').text
          TrustlinkLink.create page: page['url'], anchor: anchor, text: text, url: url
          say "   Added #{anchor} #{text} #{url}"
        end
      end
    end
  end
end

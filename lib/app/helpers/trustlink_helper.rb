module TrustlinkHelper
  def trustlink_links
    options = { links: TrustlinkLink.where(page: request.path) }
    if TrustlinkConfig.bot_ips.include?(request.remote_addr)
      options.merge!( start: TrustlinkConfig.start_code )
      options.merge!( stop:  TrustlinkConfig.stop_code )
    end
    render template: 'trustlink/links', locals: options
  end
end

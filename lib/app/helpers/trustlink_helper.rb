module TrustlinkHelper
  def trustlink_links options
    links = TrustlinkPage.where(page: request.path)
    render collection: 'trustlink/item', object: links
  end
  
  # def debug
  #   <<-END
  #   REMOTE_ADDR=#{request.remote_addr}
  #   request_uri=$self->{tl_request_uri}
  #   charset=$self->{tl_charset}
  #   is_static=$self->{tl_is_static}
  #   multi_site=$self->{tl_multi_site}
  #   file_size=$self->{tl_file_size}
  #   lc_links_count=$self->{tl_links_count}
  #   left_links_count=$self->{tl_links_count}
  #   END
  # end
end

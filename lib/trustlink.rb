module Trustlink
  require 'trustlink/railtie' if defined?(Rails)
  require 'app/helpers/trustlink_helper'

  path = File.join(File.dirname(__FILE__), 'app', 'models')
  $LOAD_PATH << path

  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
  ActionView::Base.send :include, TrustlinkHelper
  ActionController::Base.prepend_view_path File.join(File.dirname(__FILE__), 'app/views')
end

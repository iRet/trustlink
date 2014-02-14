require 'rubygems'
require 'bundler/setup'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment', __FILE__)

require 'rspec/rails'
require 'fakeweb'
require 'fakeweb_matcher'
require 'trustlink'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # some (optional) config here
end

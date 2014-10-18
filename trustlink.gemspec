$:.push File.expand_path("../lib", __FILE__)

require "trustlink/version"

Gem::Specification.new do |s|
  s.name        = "trustlink"
  s.version     = Trustlink::VERSION
  s.authors     = ["Artyom Nikolaev"]
  s.email       = ["artyom@a22.in"]
  s.homepage    = "https://github.com/iRet/trustlink"
  s.summary     = "Trustlink.ru Ruby On Rails module"
  s.description = "Trustlink.ru links exchange system integration"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "nokogiri"
  s.add_dependency "domainatrix"

  s.add_development_dependency "rspec", "~> 2.99.0"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "fakeweb-matcher"
  s.add_development_dependency "sqlite3"
end

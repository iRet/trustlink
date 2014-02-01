$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "trustlink/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "trustlink"
  s.version     = Trustlink::VERSION
  s.authors     = ["Trustlink", "Artyom Nikolaev"]
  s.email       = ["artyom@a22.in"]
  s.homepage    = "https://github.com/iRet/trustlink"
  s.summary     = "Trustlink Ruby On Rails module."
  s.description = "Trustlink integration."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "php-serialize", "~> 1.1.0"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
end

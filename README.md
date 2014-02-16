##Trustlink module for Ruby On Rails

[![Gem Version](https://badge.fury.io/rb/trustlink.png)](http://badge.fury.io/rb/trustlink)
[![Build Status](https://travis-ci.org/iRet/trustlink.png?branch=master)](https://travis-ci.org/iRet/trustlink)

###Rewritten from scratch

### Changes
* parsing xml file instead of php serialized string
* storing in database instead of text file
* requesting by rake task instead of checking on every page load
* customizable rails friendly erb templates

### Installation
Include the gem in your Gemfile:
```ruby
gem 'trustlink'
```

#### Preparing db
* `rails g trustlink:migration`
* `rake db:migrate`

#### Generating config
* create config/trustlink.yml
```yml
key: _YOUR_TRUSTLINK_HASH_
domain: example.com
encoding: UTF-8
```

#### Inserting links
Simply put helper call in desired place. Like this:
```ruby
<%= trustlink_links -%>
```

#### Fetching links
* `rake trustlink:fetch`

Run it by cron or use whenever gem or something other way you like.

#### Customizing templates (optional)
* `rails g trustlink:views`

Templates will be copied to views/trustlink folder.

### Notes
* In _link.html.erb first and last string inserting trustlink code recognized by trustlink bots. It should not be removed. Also important to levae url untouched.
* By default no style included. You can use styles extracted from trustlink's template. Just replace class to 'ads' used by default or use your own.
* Multi-domain feature currently not supported. Ask if you need this feature.

For more information please follow http://www.trustlink.ru/

License
-------
This project rocks and uses MIT-LICENSE.
Copyright © 2014 Artyom Nikolaev and Trustlink

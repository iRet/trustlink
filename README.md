#Trustlink module for Ruby On Rails

Rewritten from scratch.
======================

### Changes
* parsing xml file instead of php serialized string
* storing in database instead of text file
* requesting by rake task instead of checking on every page load
* customizable rails friendly erb remplates

### Installation

#### preparing db
* `rails g trustlink:migration`
* `rake db:migrate`

#### generating config
* `create config/trustlink.yml` 
```yml
key: _YOUR_TRUSTLINK_HASH_
domain: example.com
encoding: UTF-8
```

#### customizing templates (optional)
* `rails g trustlink:views`
Templates will be copied to views/trustlink folder.

#### fetching links
* `rake trustlink:fetch`
Run it by cron or use whenever gem or something other way you like.

### Notes
* In _link.html.erb first and last string inserting trustlink code recognized by trustlink bots. It should not be removed. Also important leve url untouched.
* By default no style included. You can use styles extracted from trustlink's template. Just replace class to 'ads' used by default or Use your own.
* Multidomain feature currently not supported. 

For more information please follow http://www.trustlink.ru/

License
-------
This project rocks and uses MIT-LICENSE.

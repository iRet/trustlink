class Trustlink::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/trustlink.rake'
  end
end
  
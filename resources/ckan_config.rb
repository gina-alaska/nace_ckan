resource_name :ckan_config

property :variables, Hash, required: true

action :create do
  template new_resource.name do
    source 'production.ini.erb'
    variables new_resource.variables
    action :create
  end
end

resource_name :ckan_config

property :site_url, String, required: true
property :variables, Hash, required: true
property :s3filestore, Hash, default: {}
property :database, Hash, default: {}
property :cookbook, String, default: 'nace-ckan'
property :storage_location, String, required: true
property :session_secret, String, required: true
property :instance_uuid, String, required: true

action :create do
  active_plugins = node['ckan']['plugins'].to_hash.select { |k,v| v }.keys

  # convert to hash so we can update config variables
  config_vars = new_resource.variables.to_hash
  config_vars.merge!(new_resource.s3filestore)
  config_vars.merge!(new_resource.database)
  config_vars.merge!({
    site_url: new_resource.site_url,
    ckan_plugins: active_plugins.join(' '),
    storage_location: new_resource.storage_location,
    session_secret: new_resource.session_secret,
    instance_uuid: new_resource.instance_uuid
  })

  template new_resource.name do
    source 'production.ini.erb'
    cookbook new_resource.cookbook
    variables config_vars
    action :create
  end
end

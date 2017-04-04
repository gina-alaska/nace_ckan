package %w(postfix libpq5 nginx)

service 'nginx' do
  action [:disable, :stop]
end

httpd_service 'ckan' do
  action [:create, :start]
  listen_ports ['8080']
end

httpd_service 'datapusher' do
  action [:create, :start]
  listen_ports ['8800']
end

httpd_module 'wsgi' do
  instance 'ckan'
  action :create
end

ckan_package 'ckan' do
  owner node['ckan']['system_user']
  group node['ckan']['system_group']
end

httpd_config 'ckan_default' do
  source 'ckan_default.erb'
  instance 'ckan'
  variables ({ 'server_name' => 'localhost', 'processes' => '2', 'threads' => '15' })
  action :create
end

httpd_config 'datapusher' do
  source 'datapusher.erb'
  instance 'datapusher'
  variables ({ 'server_name' => 'localhost', 'processes' => '2', 'threads' => '15' })
  action :create
end

directory node['ckan']['storage_location'] do
  owner node['ckan']['system_user']
  group node['ckan']['system_group']
  mode '0775'
  recursive true
end

node.default['ckan']['plugins'] = %w(stats text_view image_view recline_view nasa_ace nasa_ace_actions nasa_ace_datasetform resource_proxy geo_view geojson_view wmts_view group_private_datasets)

if node['ckan']['enable_s3filestore']
  include_recipe "nace-ckan::s3filestore"
  node.default['ckan']['plugins'] << 's3filestore'
end

if (node['googleanalytics']['id'] != '')
  include_recipe "nace-ckan::googleanalytics"
  node.default['ckan']['plugins'] << 'googleanalytics'
end

include_recipe "nace-ckan::theme"
include_recipe "nace-ckan::plugins"
include_recipe "nace-ckan::private-datasets"

include_recipe 'nace-ckan::config'

include_recipe 'nace-ckan::initdb'

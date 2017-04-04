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

include_recipe "nace-ckan::theme"
include_recipe "nace-ckan::plugins"
include_recipe "nace-ckan::private-datasets"

ckan_config '/etc/ckan/default/production.ini' do
  storage_location node['ckan']['storage_location']
  session_secret '/LQ1h6/Sl0EFEF1maYhFs0Sxo' # TODO: changeme!
  instance_uuid '200e5ca3-cffd-47aa-a93e-4c40bb81ce2c' #TODO: changeme!
  variables node['ckan']['config']
  notifies :reload, 'httpd_service[ckan]'
end

include_recipe 'nace-ckan::initdb'

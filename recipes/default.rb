#
# Cookbook Name:: nace-ckan
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2016 UAF GINA
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

apt_update 'system' do
  action :periodic
  frequency 86_400
end

package 'git'

package 'libpq5' do
  action :install
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

package 'nginx'

service 'nginx' do
  action [:disable, :stop]
end

remote_file "#{Chef::Config[:file_cache_path]}/python-ckan_2.5-trusty_amd64.deb" do
  source 'http://packaging.ckan.org/python-ckan_2.5-trusty_amd64.deb'
  mode '0644'
  action :create_if_missing
end

dpkg_package 'python-ckan_2.5-trusty_amd64.deb' do
  source "#{Chef::Config[:file_cache_path]}/python-ckan_2.5-trusty_amd64.deb"
  action :install
  notifies :run, 'execute[fix_ckan_permissions]', :immediately
end

execute 'fix_ckan_permissions' do
  command "chown -R #{node['ckan']['system_user']}:#{node['ckan']['system_group']} /usr/lib/ckan"
  action :nothing
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

ckan_plugins_list = 'stats text_view image_view recline_view nasa_ace resource_proxy geo_view geojson_view wmts_view group_private_datasets'

if (node['ckan']['aws_access_key_id'] != '' && node['ckan']['aws_secret_access_key'] != '' && node['ckan']['aws_bucket_name'] != '' && node['ckan']['aws_storage_path'] != '')
  include_recipe "nace-ckan::s3filestore"
  ckan_plugins_list = ckan_plugins_list + ' s3filestore'
end

if (node['loopback']['username'] != '' && node['loopback']['password'] != '' && node['loopback']['email'] != '' && node['loopback']['login_url'] != '' && node['loopback']['user_url'] != '' && node['loopback']['group_url'] != '')
  include_recipe "nace-ckan::loopback"
  ckan_plugins_list = ckan_plugins_list + ' loopback'
end

template '/etc/ckan/default/production.ini' do
  source 'production.ini.erb'
  variables ({
    'port' => '5000',
    'site_url' => node['ckan']['site_url'],
    'session_secret' => '/LQ1h6/Sl0EFEF1maYhFs0Sxo',
    'instance_uuid' => '200e5ca3-cffd-47aa-a93e-4c40bb81ce2c',
    'postgresql_url' => "postgresql://#{node['ckan']['db_username']}:#{node['ckan']['db_password']}@#{node['ckan']['db_address']}/#{node['ckan']['db_name']}",
    'postgresql_datastore_write_url' => "postgresql://#{node['ckan']['db_username']}:#{node['ckan']['db_password']}@#{node['ckan']['db_address']}/#{node['ckan']['db_datastore_name']}",
    'postgresql_datastore_read_url' => "postgresql://#{node['ckan']['db_username']}:#{node['ckan']['db_password']}@#{node['ckan']['db_address']}/#{node['ckan']['db_datastore_name']}",
    'solr_url' => "http://#{node.ckan.solr_url}:8983/solr",
    'ckan_plugins' => "#{ckan_plugins_list}",
    'ckan_default_views' => 'image_view text_view recline_view nasa_ace geo_view geojson_view wmts_view',
    'ckan_site_title' => node['ckan']['site_title'],
    'ckan_site_logo_path' => node['ckan']['site_logo_path'],
    'ckan_site_favicon' => node['ckan']['site_favicon'],
    'ckan_datapusher_url' => "#{node['ckan']['site_url']}:8800/",
    'ckan_storage_location' => node['ckan']['storage_location'],
    'ckanext_spatial_mapbox_id' => node['ckan']['spatial_mapbox_id'],
    'ckanext_spatial_mapbox_token' => node['ckan']['spatial_mapbox_token']
  })
  action :create
  notifies :reload, 'httpd_service[ckan]', :delayed
end

include_recipe "nace-ckan::initdb"

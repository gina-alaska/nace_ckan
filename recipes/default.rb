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

template '/etc/ckan/default/production.ini' do
  source 'production.ini.erb'
  variables ({
    'port' => '5000',
    'site_url' => node['ckan']['site_url'],
    'session_secret' => '/LQ1h6/Sl0EFEF1maYhFs0Sxo',
    'instance_uuid' => '200e5ca3-cffd-47aa-a93e-4c40bb81ce2c',
    'postgresql_url' => "postgresql://#{node.ckan.db_username}:#{node.ckan.db_password}@#{node.ckan.db_address}/#{node.ckan.db_name}",
    'postgresql_datastore_write_url' => "postgresql://#{node.ckan.db_username}:#{node.ckan.db_password}@#{node.ckan.db_address}/#{node.ckan.db_datastore_name}",
    'postgresql_datastore_read_url' => "postgresql://#{node.ckan.db_username}:#{node.ckan.db_password}@#{node.ckan.db_address}/#{node.ckan.db_datastore_name}",
    'solr_url' => 'http://127.0.0.1:8983/solr',
    'ckan_plugins' => 'stats text_view image_view recline_view',
    'ckan_default_views' => 'image_view text_view recline_view',
    'ckan_site_title' => 'CKAN',
    'ckan_site_logo_path' => '/base/images/ckan-logo.png',
    'ckan_site_favicon' => '/images/icons/ckan.ico',
    'ckan_datapusher_url' => 'http://127.0.0.1:8800/'
  })
  action :create
end

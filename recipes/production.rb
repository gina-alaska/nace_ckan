#
# Cookbook Name:: nace-ckan
# Recipe:: production
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

include_recipe "nace-ckan::default"

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
    'solr_url' => "http://#{node.ckan.solr_url}:8983/solr",
    'ckan_plugins' => 'stats text_view image_view recline_view nasa_ace',
    'ckan_default_views' => 'image_view text_view recline_view nasa_ace',
    'ckan_site_title' => 'NASA Arctic Collaborative Environment',
    'ckan_site_logo_path' => '/base/images/ace_title.png',
    'ckan_site_favicon' => '/base/images/ace_logo.png',
    'ckan_datapusher_url' => 'http://127.0.0.1:8800/'
  })
  action :create
end

git '/usr/lib/ckan/default/src/ckanext-nasa_ace' do
  repository 'https://github.com/gina-alaska/ckanext-nasa_ace.git'
  checkout_branch 'nasa-ace-theme'
  action :sync
end

bash 'install NASA ACE theme' do
  code '/usr/lib/ckan/default/bin/python setup.py develop'
  cwd '/usr/lib/ckan/default/src/ckanext-nasa_ace'
end

execute 'init db' do
  command 'ckan db init'
  notifies :create, 'file[init-db]', :immediately
  retries 1
  retry_delay 5
  not_if { ::File.exist?('/root/initialized-db') }
end

file 'init-db' do
  path '/root/initialized-db'
  action :nothing
  notifies :restart, 'httpd_service[ckan]', :immediately
end

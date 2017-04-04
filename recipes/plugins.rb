#
# Cookbook Name:: nace-ckan
# Recipe:: plugins
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
%w(stats text_view image_view recline_view resource_proxy geojson_view wmts_view nasa_ace nasa_ace_actions nasa_ace_datasetform group_private_datasets).each do |plugin|
  ckan_plugin plugin do
    action :activate
  end
end

ckan_plugin 'geo_view' do
  repository 'https://github.com/pduchesne/ckanext-geoview.git'
  owner node['ckan']['system_user']
  group node['ckan']['system_group']

  action [:install, :activate]
end

ckan_plugin 'googleanalytics' do
  package 'https://github.com/ckan/ckanext-googleanalytics/archive/v2.0.2.tar.gz'
  owner node['ckan']['system_user']
  group node['ckan']['system_group']

  only_if { node['ckan']['googleanalytics'] }
  action [:install, :activate]
end

ckan_plugin 's3filestore' do
  package 'https://github.com/okfn/ckanext-s3filestore/archive/v0.0.5.tar.gz'
  owner node['ckan']['system_user']
  group node['ckan']['system_group']

  only_if { node['ckan']['enable_s3filestore'] }
  action [:install, :activate]
end

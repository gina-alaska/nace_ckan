#
# Cookbook Name:: nace-ckan
# Recipe:: private-datasets
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

git '/usr/lib/ckan/default/src/ckanext-loopback' do
  user node['ckan']['system_user']
  group node['ckan']['system_group']
  repository 'https://github.com/gina-alaska/ckanext-loopback.git'
  revision 'master'
  action :sync
end

cookbook_file '/usr/lib/ckan/default/src/ckanext-loopback/ckanext/loopback/plugin.py' do
  source 'loopback-plugin.py'
  owner 'root'
  group 'root'
  mode 00644
end

bash 'install CKAN extension for loopback integration' do
  code '/usr/lib/ckan/default/bin/python setup.py develop'
  cwd '/usr/lib/ckan/default/src/ckanext-loopback'
end
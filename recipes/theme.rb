#
# Cookbook Name:: nace-ckan
# Recipe:: theme
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

package 'postgresql-client'
package 'python-dev'

git '/usr/lib/ckan/default/src/ckanext-nasa_ace' do
  user node['ckan']['system_user']
  group node['ckan']['system_group']
  repository 'https://github.com/gina-alaska/ckanext-nasa_ace.git'
  revision 'merge_master'
  action :sync
end

if node['cometchat']['chat_url'] != 'http://localhost'
  package 'mysql-client'
  package 'libmysqlclient-dev'

  python_package 'MySQL-python' do
    python '/usr/lib/ckan/default/bin/python'
    action :install
  end

  directory '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/templates/snippets/' do
    action :create
  end

  template '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/templates/snippets/cometchat-css.html' do
    source 'cometchat-css.html.erb'
    variables ({
        'cometchat_url' => node['cometchat']['chat_url']
    })
    action :create
  end

  template '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/templates/snippets/cometchat-js.html' do
    source 'cometchat-js.html.erb'
    variables ({
        'cometchat_url' => node['cometchat']['chat_url']
      })
    action :create
  end

  template '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/config.py' do
    source 'config.py.erb'
    variables ({
        'cometchat_db_host' => node['cometchat']['db_host'],
        'cometchat_db_name' => node['cometchat']['db_name'],
        'cometchat_db_username' => node['cometchat']['db_username'],
        'cometchat_db_password' => node['cometchat']['db_password']
      })
      action :create
  end
else
  cookbook_file '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/plugin.py' do
    source 'plugin.py'
    owner 'root'
    group 'root'
    mode 00755
    action :create
  end
end

bash 'install NASA ACE theme' do
  code '/usr/lib/ckan/default/bin/python setup.py develop'
  cwd '/usr/lib/ckan/default/src/ckanext-nasa_ace'
end

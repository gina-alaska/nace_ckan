#
# Cookbook Name:: nace-ckan
# Recipe:: cometchat
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

package 'php5'
package 'php5-mysql'

remote_file '/var/www/cometchat.zip' do
  source 'https://s3-us-west-2.amazonaws.com/gina-packages/cometchat.zip'
  owner 'www-data'
  group 'www-data'
  mode '0755'
  action :create_if_missing
  notifies :run, 'execute[unzip_commetchat]', :immediately
end

execute "unzip_cometchat" do
  command 'unzip /var/www/cometchat.zip'
  cwd '/var/www/'
  action :nothing
  notifies :create, "template[/var/www/cometchat/integration.php]", :immediately
end

template '/var/www/cometchat/integration.php' do
  source 'cometchat_integration.erb'
  variables ({
      'db_host' => node['cometchat']['db_host'],
      'db_name' => node['cometchat']['db_name'],
      'db_username' => node['cometchat']['db_username'],
      'db_password' => node['cometchat']['db_password']
    })
  action :nothing
  notifies :create, 'httpd_config[cometchat]', :immediately
end

httpd_config 'cometchat' do
  source 'cometchat.erb'
  instance 'cometchat'
  variables ({ 'server_name' => 'localhost' })
  action :nothing
  notifies :get, 'http_request[install_cometchat]', :immediately
end

file '/var/www/cometchat/install.php' do
  action :nothing
  notifies :reload, 'httpd_service[cometchat]', :delayed
end

#if File.exist?('/var/www/cometchat/install.php')
http_request 'install_cometchat' do
  url 'http://localhost/install.php'
  action :nothing
  notifies :delete, 'file[/var/www/cometchat/install.php]', :immediately
end
#end

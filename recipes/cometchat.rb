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

node.default['cometchat']['on_startup'] = True

apt_update 'system' do
  action :periodic
  frequency 86_400
end

package 'php5'
package 'php5-mysql'
package 'postgresql-client'
package 'mysql-client'
package 'php5-pgsql'
package 'unzip'

cookbook_file '/var/www/cometchat.zip' do
  source 'cometchat.zip'
  owner 'www-data'
  group 'www-data'
  mode '0755'
  action :create_if_missing
  notifies :run, 'execute[unzip_cometchat]', :immediately
end

execute 'unzip_cometchat' do
  command 'unzip /var/www/cometchat.zip'
  cwd '/var/www/'
  action :nothing
  notifies :create, "template[/var/www/cometchat/config.php]", :immediately
end

template '/var/www/cometchat/config.php' do
  source 'cometchat_config.erb'
  owner node['cometchat']['system_user']
  group node['cometchat']['system_group']
  variables ({
      'chat_server_url' => node['cometchat']['chat_url']
  })
  action :nothing
  notifies :create, "template[/var/www/cometchat/integration.php]", :immediately
end

template '/var/www/cometchat/integration.php' do
  source 'cometchat_integration.erb'
  owner node['cometchat']['system_user']
  group node['cometchat']['system_group']
  variables ({
      'db_host' => node['cometchat']['db_host'],
      'db_name' => node['cometchat']['db_name'],
      'db_username' => node['cometchat']['db_username'],
      'db_password' => node['cometchat']['db_password']
    })
  action :nothing
  notifies :run, 'execute[fix_chat_permissions]', :immediately
end

execute 'fix_chat_permissions' do
  command "chown -R #{node['cometchat']['system_user']}:#{node['cometchat']['system_group']} /var/www/cometchat"
  action :nothing
  notifies :run, 'execute[fix_chat_writable_directory_mode]', :immediately
end

execute 'fix_chat_writable_directory_mode' do
  command "chmod -R 777 /var/www/cometchat/writable"
  action :nothing
  notifies :create, 'httpd_config[cometchat]', :immediately
end

httpd_config 'cometchat' do
  source 'cometchat.erb'
  instance 'cometchat'
  variables ({ 'chat_server_name' => node['cometchat']['chat_hostname'] })
  action :nothing
  notifies :reload, 'httpd_service[cometchat]', :immediately
  notifies :get, 'http_request[install_cometchat]', :delayed
end

file '/var/www/cometchat/install.php' do
  action :nothing
end

#if File.exist?('/var/www/cometchat/install.php')
http_request 'install_cometchat' do
  url "http://#{node['cometchat']['chat_url']}/install.php"
  action :nothing
  notifies :create, 'template[/tmp/import_users.sh]', :immediately
  # notifies :delete, 'file[/var/www/cometchat/install.php]', :immediately
end

template '/tmp/import_users.sh' do
  source 'import_users.erb'
  variables ({
      'pgsql_password' => node['ckan']['db_password'],
      'pgsql_user' => node['ckan']['db_username'],
      'pgsql_db_name' => node['ckan']['db_name'],
      'pgsql_db_host' => node['ckan']['db_address'],
      'mysql_host_name' => node['cometchat']['db_host'],
      'mysql_user' => node['cometchat']['db_username'],
      'mysql_password' => node['cometchat']['db_password'],
      'mysql_db_name' => node['cometchat']['db_name']
    })
  action :nothing
  notifies :run, 'execute[import_users]', :immediately
end

execute 'import_users' do
  command 'bash /tmp/import_users.sh'
  action :nothing
  notifies :delete, ''
end

#end
httpd_module 'rewrite' do
  instance 'cometchat'
  action :create
end

httpd_module 'php5' do
  instance 'cometchat'
  action :create
end

httpd_module 'headers' do
  instance 'cometchat'
  action :create
end

httpd_service 'cometchat' do
  action [:create, :start]
  listen_ports ['80']
  mpm 'prefork'
end

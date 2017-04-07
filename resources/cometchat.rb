resource_name :cometchat

property :host, String, required: true
property :http_protocol, String, default: 'http'
property :source, String
property :owner, String, required: true
property :group, String, required: true
property :dbconfig, Hash, default: {}

action :install do
  package %w(php5 php5-mysql php5-curl unzip)

  # TODO: convert this to download from S3 instead of having it live in the cookbook
  cookbook_file '/var/www/cometchat.zip' do
    source 'cometchat.zip'
    cookbook 'nace-ckan'

    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    mode '0755'
    action :create_if_missing
    notifies :run, 'execute[unzip_cometchat]', :immediately
  end

  execute 'unzip_cometchat' do
    command 'unzip /var/www/cometchat.zip'
    cwd '/var/www/'
    action :nothing
  end

  template '/var/www/cometchat/config.php' do
    source 'cometchat_config.erb'
    cookbook 'nace-ckan'

    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    variables ({
        'chat_server_url' => "#{new_resource.http_protocol}://#{new_resource.host}"
    })
    notifies :reload, 'httpd_service[cometchat]', :delayed
  end

  template '/var/www/cometchat/integration.php' do
    source 'cometchat_integration.erb'
    cookbook 'nace-ckan'

    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    variables (new_resource.dbconfig)
    notifies :reload, 'httpd_service[cometchat]', :delayed
  end

  template '/var/www/cometchat/install.php' do
    source 'install.php.erb'
    cookbook 'nace-ckan'

    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    variables ({
        'chat_server_url' => "#{new_resource.http_protocol}://#{new_resource.host}"
    })
    notifies :get, 'http_request[install_cometchat]', :delayed
  end

  execute 'fix_chat_permissions' do
    command "chown -R #{new_resource.owner}:#{new_resource.group} /var/www/cometchat"
  end

  execute 'fix_chat_writable_directory_mode' do
    command "chmod -R 777 /var/www/cometchat/writable"
  end

  httpd_config 'cometchat' do
    source 'cometchat.erb'
    cookbook 'nace-ckan'

    instance 'cometchat'
    variables ({ 'chat_server_name' => new_resource.host })
    notifies :reload, 'httpd_service[cometchat]', :delayed
  end

  %w(rewrite php5 headers).each do |mod|
    httpd_module mod do
      instance 'cometchat'
      action :create
    end
  end

  httpd_service 'cometchat' do
    action [:create, :start]
    listen_ports ['80']
    mpm 'prefork'
  end

  http_request 'install_cometchat' do
    url "#{new_resource.http_protocol}://#{new_resource.host}/install.php"
    action :nothing
  end
end

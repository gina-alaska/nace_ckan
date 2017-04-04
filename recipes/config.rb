ckan_config = {
  'session_secret' => '/LQ1h6/Sl0EFEF1maYhFs0Sxo',
  'instance_uuid' => '200e5ca3-cffd-47aa-a93e-4c40bb81ce2c',
  'postgresql_url' => node['ckan']['postgresql_url'],
  'postgresql_datastore_write_url' => node['ckan']['postgresql_url'],
  'postgresql_datastore_read_url' => node['ckan']['postgresql_url'],
  'ckan_plugins' => node['ckan']['plugins'].join(' '),
  'ckan_datapusher_url' => "#{node['ckan']['config']['site_url']}:8800/",
  'ckan_storage_location' => node['ckan']['storage_location']
}

ckan_config '/etc/ckan/default/production.ini' do
  variables lazy { node['ckan']['config'].to_hash.merge(ckan_config) }
  notifies :reload, 'httpd_service[ckan]'
end

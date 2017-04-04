default['ckan']['storage_location'] = '/opt/ckan/data'
default['ckan']['system_user'] = 'www-data'
default['ckan']['system_group'] = 'www-data'
default['ckan']['install_path'] = '/usr/lib/ckan/default/src/'
default['ckan']['actions_dev'] = 'True'

default['ckan']['config'] = {
  'port' => '5000',
  'site_url' => 'http://localhost',
  'solr_url' => 'http://localhost:8983/solr',
  'ckan_datapusher_url' => 'http://localhost:8800/',
  'ckan_default_views' => 'image_view text_view recline_view nasa_ace geo_view geojson_view wmts_view',
  'ckan_site_title' => 'NASA Arctic Collaborative Environment',
  'ckan_site_logo_path' => '/base/images/ace_title.png',
  'ckan_site_favicon' => '/base/images/ace_logo.png',
  'mapbox_id' => 'gina-alaska.heb1gpfg',
  'mapbox_token' => '',
  'googleanalytics' => false
}

# NASA ACE Workspace attributes
default['ckan']['workspace_url'] = 'http://workspace.ace.uaf.edu/workspaces'
default['ckan']['workspace_email'] = 'support+ckan@gina.alaska.edu'
default['ckan']['mailserver'] = 'localhosts'

# Solr default attributes
override['solr']['checksum'] = 'ac3543880f1b591bcaa962d7508b528d7b42e2b5548386197940b704629ae851'

# Attributes for using AWS S3 Bucket for shared storage
default['ckan']['enable_s3filestore'] = false
default['ckan']['aws_access_key_id'] = ''
default['ckan']['aws_secret_access_key'] = ''
default['ckan']['aws_bucket_name'] = ''
default['ckan']['aws_storage_path'] = ''

# Attributes for LoopBack
default['loopback']['username'] = ''
default['loopback']['password'] = ''
default['loopback']['email'] = ''
default['loopback']['login_url'] = ''
default['loopback']['user_url'] = ''
default['loopback']['group_url'] = ''

# Attributes for CometChat
default['cometchat']['system_user'] = 'www-data'
default['cometchat']['system_group'] = 'www-data'
default['cometchat']['chat_url'] = 'http://localhost'
default['cometchat']['chat_hostname'] = 'localhost'
default['cometchat']['db_host'] = ''
default['cometchat']['db_name'] = ''
default['cometchat']['db_username'] = ''
default['cometchat']['db_password'] = ''

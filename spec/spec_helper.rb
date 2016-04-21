require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'
  config.file_cache_path = '/var/chef/cache'
end
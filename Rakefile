task default: [:lint, :style, :unit]

desc 'Run foodcritic linting'
task :lint do
  sh 'foodcritic -X spec .'
end

desc 'Run Rubocop style'
task :style do
  sh 'rubocop'
end

desc 'Run unit tests with ChefSpec'
task :unit do
  sh 'chef exec rspec --color -fd'
end

desc 'Run functional tests with Serverspec'
task :functional do
  sh 'kitchen test'
end

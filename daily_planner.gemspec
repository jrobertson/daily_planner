Gem::Specification.new do |s|
  s.name = 'daily_planner'
  s.version = '0.2.1'
  s.summary = 'Creates a daily-planner.txt template file'
  s.authors = ['James Robertson']
  s.files = Dir['lib/daily_planner.rb']
  s.add_runtime_dependency('dynarex', '~> 1.6', '>=1.6.1')
  s.signing_key = '../privatekeys/daily_planner.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/daily_planner'
end

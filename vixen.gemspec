Gem::Specification.new do |s|
  s.name = 'vixen'
  s.version = '0.0.11'
  s.date = '2012-11-20'


  s.summary = 'Ruby bindings for VMware VIX API'
  s.description = <<-EOF
  Vixen is an easy way to interact with VMware virtual machines from Ruby. 

  Vixen is not affliated with or endorsed by VMware.
EOF
  s.author = 'Jeff Weiss'
  s.email = 'vixen-gem@jeffweiss.org'
  s.executables = ['vixen']
  s.files = ['bin/vixen'] + (`git ls-files`.split("\n"))
  s.require_paths = ['lib']
  s.platform = Gem::Platform::RUBY
  s.homepage = "https://github.com/jeffweiss/vixen"
  s.licenses = ['Apache-2', 'MIT']
  s.required_ruby_version = '>= 1.8.7'
  s.add_runtime_dependency 'ffi', '>= 1.1.5'
  s.add_runtime_dependency 'facter', '>= 1.6.14'
end

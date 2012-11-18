Gem::Specification.new do |s|
  s.name = 'vixen'
  s.version = '0.0.1'
  s.summary = 'Ruby bindings for VMware VIX API'
  s.description = <<-EOF
  Vixen is a way to interact with VMware virtual machines from Ruby. 
  It currently only supports VMware Fusion 5.
EOF
  s.author = 'Jeff Weiss'
  s.email = 'vixen-gem@jeffweiss.org'
  s.files = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.platform = Gem::Platform::CURRENT
  s.homepage = "https://github.com/jeffweiss/vixen"
  s.licenses = ['Apache-2', 'MIT']
  s.required_ruby_version = '>= 1.8.7'
  s.add_runtime_dependency 'ffi', '~> 1.1.5'
end

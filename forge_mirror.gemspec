lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "forge_mirror/version"

Gem::Specification.new do |spec|
  spec.name          = "forge_mirror"
  spec.version       = ForgeMirror::VERSION
  spec.authors       = ["Garrett Rowell"]
  spec.email         = ["garrett.rowell@puppet.com"]

  spec.summary       = %q{Write a short summary, because RubyGems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "http://foo.com"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://foo.com"
  spec.metadata["changelog_uri"] = "http://foo.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables << 'forge_mirror'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"

  spec.add_dependency "puppet_forge"
  spec.add_dependency "puppetfile-resolver"
  spec.add_dependency "octokit"
  spec.add_dependency "rugged", "~> 0.28.5"
  spec.add_dependency "thor"
  spec.add_dependency 'deep_merge'

end

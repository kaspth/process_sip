# frozen_string_literal: true

require_relative "lib/process_sip/version"

Gem::Specification.new do |spec|
  spec.name = "process_sip"
  spec.version = ProcessSip::VERSION
  spec.authors = ["Kasper Timm Hansen"]
  spec.email = ["hey@kaspth.com"]

  spec.summary  = "Make ad-hoc adapters for CLIs to interface with from Ruby."
  spec.homepage = "https://github.com/kaspth/process_sip"
  spec.license  = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end

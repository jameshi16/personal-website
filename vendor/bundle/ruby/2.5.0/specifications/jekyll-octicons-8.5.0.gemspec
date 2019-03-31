# -*- encoding: utf-8 -*-
# stub: jekyll-octicons 8.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-octicons".freeze
  s.version = "8.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["GitHub Inc.".freeze]
  s.date = "2019-02-27"
  s.description = "A jekyll liquid plugin that makes including svg Octicons simple.".freeze
  s.email = ["support@github.com".freeze]
  s.homepage = "https://github.com/primer/octicons".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.7".freeze
  s.summary = "Octicons jekyll liquid tag".freeze

  s.installed_by_version = "2.7.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jekyll>.freeze, ["~> 3.1"])
      s.add_runtime_dependency(%q<octicons>.freeze, ["= 8.5.0"])
    else
      s.add_dependency(%q<jekyll>.freeze, ["~> 3.1"])
      s.add_dependency(%q<octicons>.freeze, ["= 8.5.0"])
    end
  else
    s.add_dependency(%q<jekyll>.freeze, ["~> 3.1"])
    s.add_dependency(%q<octicons>.freeze, ["= 8.5.0"])
  end
end

# -*- encoding: utf-8 -*-
# stub: jekyll-theme-8bit 0.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-theme-8bit".freeze
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Juliano Fernandes".freeze]
  s.date = "2023-07-22"
  s.email = ["julianofernandes@gmail.com".freeze]
  s.homepage = "https://github.com/julianolf/jekyll-theme-8bit".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.3.5".freeze
  s.summary = "A Jekyll theme inspired by classic 8bit games.".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<jekyll>.freeze, [">= 3.8.5", "< 4.4.0"])
    s.add_runtime_dependency(%q<jekyll-paginate>.freeze, ["~> 1.1.0"])
    s.add_runtime_dependency(%q<jekyll-seo-tag>.freeze, ["~> 2.8.0"])
    s.add_development_dependency(%q<kramdown-parser-gfm>.freeze, ["~> 1.1.0"])
    s.add_development_dependency(%q<webrick>.freeze, ["~> 1.8.1"])
    s.add_development_dependency(%q<html-proofer>.freeze, ["~> 5.0.7"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0.6"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.54.2"])
    s.add_development_dependency(%q<w3c_validators>.freeze, ["~> 1.3.7"])
  else
    s.add_dependency(%q<jekyll>.freeze, [">= 3.8.5", "< 4.4.0"])
    s.add_dependency(%q<jekyll-paginate>.freeze, ["~> 1.1.0"])
    s.add_dependency(%q<jekyll-seo-tag>.freeze, ["~> 2.8.0"])
    s.add_dependency(%q<kramdown-parser-gfm>.freeze, ["~> 1.1.0"])
    s.add_dependency(%q<webrick>.freeze, ["~> 1.8.1"])
    s.add_dependency(%q<html-proofer>.freeze, ["~> 5.0.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0.6"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 1.54.2"])
    s.add_dependency(%q<w3c_validators>.freeze, ["~> 1.3.7"])
  end
end

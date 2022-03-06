# -*- encoding: utf-8 -*-
# stub: mustache 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "mustache".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Chris Wanstrath".freeze, "Magnus Holm".freeze, "Pieter van de Bruggen".freeze, "Ricardo Mendes".freeze]
  s.date = "2019-12-03"
  s.description = "Inspired by ctemplate, Mustache is a framework-agnostic way to render\nlogic-free views.\n\nAs ctemplates says, \"It emphasizes separating logic from presentation:\nit is impossible to embed application logic in this template\nlanguage.\n\nThink of Mustache as a replacement for your views. Instead of views\nconsisting of ERB or HAML with random helpers and arbitrary logic,\nyour views are broken into two parts: a Ruby class and an HTML\ntemplate.\n".freeze
  s.email = "rokusu@gmail.com".freeze
  s.executables = ["mustache".freeze]
  s.files = ["bin/mustache".freeze]
  s.homepage = "https://github.com/mustache/mustache".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Mustache is a framework-agnostic way to render logic-free views.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.6"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.3"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.4"])
    s.add_development_dependency(%q<benchmark-ips>.freeze, [">= 0"])
    s.add_development_dependency(%q<ruby-prof>.freeze, [">= 0"])
    s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.1"])
    s.add_development_dependency(%q<ronn>.freeze, ["~> 0.7"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.6"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.3"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
    s.add_dependency(%q<benchmark-ips>.freeze, [">= 0"])
    s.add_dependency(%q<ruby-prof>.freeze, [">= 0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.1"])
    s.add_dependency(%q<ronn>.freeze, ["~> 0.7"])
  end
end

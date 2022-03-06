# -*- encoding: utf-8 -*-
# stub: rugged 1.4.2 ruby lib
# stub: ext/rugged/extconf.rb

Gem::Specification.new do |s|
  s.name = "rugged".freeze
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "msys2_mingw_dependencies" => "libssh2 cmake" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Scott Chacon".freeze, "Vicent Marti".freeze]
  s.date = "2022-02-28"
  s.description = "Rugged is a Ruby bindings to the libgit2 linkable C Git library. This is\nfor testing and using the libgit2 library in a language that is awesome.\n".freeze
  s.email = "schacon@gmail.com".freeze
  s.extensions = ["ext/rugged/extconf.rb".freeze]
  s.files = ["ext/rugged/extconf.rb".freeze]
  s.homepage = "https://github.com/libgit2/rugged".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Rugged is a Ruby binding to the libgit2 linkable library".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0.9.0"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
  else
    s.add_dependency(%q<rake-compiler>.freeze, [">= 0.9.0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
  end
end

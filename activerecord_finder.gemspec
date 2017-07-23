# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name              = "activerecord_finder"
  s.version           = "0.1.4"
  s.author            = "Maurício Szabo"
  s.email             = "mauricio.szabo@gmail.com"
  s.homepage          = "http://github.com/mauricioszabo/arel_operators"
  s.platform          = Gem::Platform::RUBY
  s.summary           = "Better finder syntax (|, &, >=, <=) for ActiveRecord."
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- spec/*`.split("\n")
  s.require_path      = "lib"
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.md"]

  s.add_dependency("activerecord")

  s.add_development_dependency("rspec")
  s.add_development_dependency("sqlite3")
end

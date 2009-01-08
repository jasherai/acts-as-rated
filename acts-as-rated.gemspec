Gem::Specification.new do |s|
  s.name = "acts-as-rated"
  s.version = "0.4"
  s.date = "2009-01-08"
  s.summary = "Rails plugin rating system for ActiveRecord models."
  s.email = "guy.naor@famundo.com"
  s.homepage = "git://github.com/jasherai/acts-as-rated"
  s.description = "Flexible, configurable, and easy to use with the defaults. Supports 3 different ways to manage rating statistics." 
  s.has_rdoc = false
  s.authors = "Guy Noar"
  s.files = [
    "acts-as-rated.gemspec",
    "init.rb",
    "lib/acts_as_rated.rb",
    "MIT-LICENSE",
    "Rakefile",
    "README"
    ]
  s.test_files = ["test/rated_test.rb"]
end

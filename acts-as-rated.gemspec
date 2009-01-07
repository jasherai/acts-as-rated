Gem::Specification.new do |s|
  s.name = "acts-as-rated"
  s.version = "0.4"
  s.date = "2009-01-07"
  s.summary = "Rails plugin rating system for ActiveRecord models."
  s.email = "guy.naor@famundo.com"
  s.homepage = "git://github.com/sherpa99/acts-as-rated.git"
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
  s.test_files = [
    "test/database.yml",
    "test/abstract_unit.rb",
    "test/dummy_classes.rb",
    "test/migration_test.rb",
    "test/rated_test.rb",
    "test/schema.rb",
    "test/fixtures/books.yml",
    "test/fixtures/cars.yml",
    "test/fixtures/movies.yml",
    "test/fixtures/my_statistics.yml",
    "test/fixtures/my_stats_ratings.yml",
    "test/fixtures/no_rater_ratings.yml",
    "test/fixtures/rating_statistics.yml",
    "test/fixtures/ratings.yml",
    "test/fixtures/stats_ratings.yml",
    "test/fixtures/users.yml",
    "test/fixtures/videos.yml",
    "test/fixtures/migrations/001_add_rating_tables.rb"  
    ]
end

ENV['NO_SCHEMA_LOAD'] = 'true' 
require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'dummy_classes')

if ActiveRecord::Base.connection.supports_migrations? 
  class MigrationTest < Test::Unit::TestCase
    self.use_transactional_fixtures = false
   
    # Defeat table creation!
    def create_fixtures(*table_names)
    end

    def setup
      teardown # Same in our case...
    end
    
    def teardown
      ActiveRecord::Base.connection.initialize_schema_information
      ActiveRecord::Base.connection.update "UPDATE schema_info SET version = 0"

      [Movie, Book, Car, NoRaterRating, Rating, User, Video, RatingStatistic, MyStatistic, StatsRating, MyStatsRating].each do |c|
        c.connection.drop_table c.table_name rescue nil
        c.reset_column_information
      end
    end
    
    # Add ratings table AND add the special stats table
    def test_add_ratings_table_migration
      verify_tables_do_not_exist
     
      # up we go...
      ActiveRecord::Migrator.up(File.dirname(__FILE__) + '/fixtures/migrations/')
      [Book, Movie, Car, Video, Truck, Tape, Film, User, Mechanic].each do |c|
        t = nil
        assert_nothing_raised { t = c.create }
        assert_respond_to t, :title
        assert_respond_to t, :rating_average unless [User, Mechanic].include?(c)
        assert t.attributes.include?('rating_avg') unless [User, Mechanic, Book, Video, Tape].include?(c) 
        assert !t.attributes.include?('rating_avg') if [User, Mechanic, Book, Video, Tape].include?(c) 
      end
      r = nil
      assert_nothing_raised { r = Rating.create }
      assert_respond_to r, :rater_id
      n = nil
      assert_nothing_raised { n = NoRaterRating.create }
      assert_raises(NoMethodError) { n.rater_id }
      assert_respond_to n, :rating
      s = nil
      assert_nothing_raised { s = RatingStatistic.create }
      assert_respond_to s, :rated_id
      assert_respond_to s, :rated_type
      assert_respond_to s, :rating_avg
      m = nil
      assert_nothing_raised { m = MyStatistic.create }
      assert_respond_to m, :rated_id
      assert_respond_to m, :rated_type
      assert_respond_to m, :rating_avg
  
      # down again
      ActiveRecord::Migrator.down(File.dirname(__FILE__) + '/fixtures/migrations/')
      verify_tables_do_not_exist
    end

    def verify_tables_do_not_exist
      [Book, Movie, Car, User, Rating, Video, NoRaterRating, RatingStatistic, MyStatistic, StatsRating, MyStatsRating].each do |c|
        assert_raises(ActiveRecord::StatementInvalid) { c.create }
      end
    end
    
  end
end

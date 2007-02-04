class AddRatingTables < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_ratings_table
    ActiveRecord::Base.create_ratings_table :with_rater => false, :table_name => 'no_rater_ratings'
    ActiveRecord::Base.create_ratings_table :with_stats_table => true, :table_name => 'stats_ratings' 
    ActiveRecord::Base.create_ratings_table :with_stats_table => true, :table_name => 'my_stats_ratings', :stats_table_name => 'my_statistics'
    
    # Movies table has the columns for the ratings added
    create_table(:movies) do |t|
      t.column :title, :text
      Movie.generate_ratings_columns t
    end

    # Books table doesn't have the columns for ratings added
    create_table(:books) do |t|
      t.column :title, :text
    end

    # Cars table has the columns for the ratings added, but is used for testing with no rater
    create_table(:cars) do |t|
      t.column :title, :text
    end
    Car.add_ratings_columns

    # Videos table has the ratings columns added as part of the table creation
    create_table(:videos) do |t|
      t.column :title, :text
    end

    # We need a users table
    create_table(:users) do |t|
      t.column :title, :text
    end

  end
  
  def self.down
    Movie.remove_ratings_columns
    Car.remove_ratings_columns
    
    drop_table :movies rescue nil
    drop_table :books rescue nil
    drop_table :users rescue nil
    drop_table :cars rescue nil
    drop_table :videos rescue nil

    ActiveRecord::Base.drop_ratings_table
    ActiveRecord::Base.drop_ratings_table :table_name => 'no_rater_ratings'
    ActiveRecord::Base.drop_ratings_table :with_stats_table => true, :table_name => 'stats_ratings'                                          
    ActiveRecord::Base.drop_ratings_table :with_stats_table => true, :table_name => 'my_stats_ratings', :stats_table_name => 'my_statistics' 
  end
end

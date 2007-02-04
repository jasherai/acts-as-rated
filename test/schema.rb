ActiveRecord::Schema.define(:version => 0) do

  create_table :users, :force => true do |t|
    t.column :title, :text
  end

  create_table :ratings, :force => true do |t|
    t.column :rater_id,   :integer 
    t.column :rated_id,   :integer
    t.column :rated_type, :string
    t.column :rating,     :decimal
  end

  create_table :stats_ratings, :force => true do |t|
    t.column :rater_id,   :integer 
    t.column :rated_id,   :integer
    t.column :rated_type, :string
    t.column :rating,     :decimal
  end

  create_table :my_stats_ratings, :force => true do |t|
    t.column :rater_id,   :integer 
    t.column :rated_id,   :integer
    t.column :rated_type, :string
    t.column :rating,     :decimal
  end

  create_table :no_rater_ratings, :force => true do |t|
    t.column :rated_id,   :integer
    t.column :rated_type, :string
    t.column :rating,     :decimal
  end

  create_table :books, :force => true do |t|
    t.column :title, :text
  end

  create_table :videos, :force => true do |t|
    t.column :title, :text
  end

  create_table :movies, :force => true do |t|
    t.column :title, :text
    t.column :rating_count, :integer
    t.column :rating_total, :decimal
    t.column :rating_avg, :decimal
  end

  create_table :cars, :force => true do |t|
    t.column :title, :text
    t.column :rating_count, :integer
    t.column :rating_total, :decimal
    t.column :rating_avg, :decimal
  end

  create_table :rating_statistics, :force => true do |t|
    t.column :rated_id,   :integer
    t.column :rated_type, :string
    t.column :rating_count, :integer
    t.column :rating_total, :decimal
    t.column :rating_avg, :decimal
  end
  
  create_table :my_statistics, :force => true do |t|
    t.column :rated_id,   :integer
    t.column :rated_type, :string
    t.column :rating_count, :integer
    t.column :rating_total, :decimal
    t.column :rating_avg, :decimal
  end
  
end

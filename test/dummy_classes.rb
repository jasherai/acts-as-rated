
class User < ActiveRecord::Base
end

class Worker < ActiveRecord::Base
  set_table_name 'users'
end

class Movie < ActiveRecord::Base
  acts_as_rated
end

class Film < ActiveRecord::Base
  set_table_name 'movies'
  acts_as_rated :rating_range => 1..5
end

class Book < ActiveRecord::Base
  acts_as_rated :rater_class => 'Worker'
end

class NoRaterRating < ActiveRecord::Base
  belongs_to :rated, :polymorphic => true
end

class StatsRating < ActiveRecord::Base
  belongs_to :rated, :polymorphic => true
  belongs_to :rater, :class_name => 'User', :foreign_key => :rater_id
end

class MyStatsRating < ActiveRecord::Base
  belongs_to :rated, :polymorphic => true
  belongs_to :rater, :class_name => 'User', :foreign_key => :rater_id
end

class Car < ActiveRecord::Base
  acts_as_rated :rating_class => 'NoRaterRating', :no_rater => true
end

class Mechanic < ActiveRecord::Base
  set_table_name 'users'
end

class Truck < ActiveRecord::Base
  set_table_name 'cars'
  acts_as_rated :rating_class => 'NoRaterRating', :no_rater => true, :rater_class => 'Mechanic'
end

class Video < ActiveRecord::Base
  acts_as_rated :with_stats_table => true, :rating_class => 'StatsRating'
end


class MyStatistic < ActiveRecord::Base
  belongs_to :rated, :polymorphic => true
end

class Tape < ActiveRecord::Base
  set_table_name 'videos'
  acts_as_rated :with_stats_table => true, :stats_class => 'MyStatistic', :rating_class => 'MyStatsRating'
end



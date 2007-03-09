require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'dummy_classes')

class RatedTest < Test::Unit::TestCase
  fixtures :cars, :movies, :books, :users, :ratings, :no_rater_ratings, :videos, :stats_ratings, :my_stats_ratings, :rating_statistics, :my_statistics

  def test_rate
    # Regular one...
    m = movies(:gone_with_the_wind)
    check_average m, 4.33
    m.rate 1, users(:sarah)
    check_average m, 3
    m = Movie.new :title => 'King Kong'
    m.rate 4, users(:john)
    assert m.new_record?
    assert_equal 4, m.rating_average
    assert_equal 1, m.rating_count
    assert_equal 4, m.rating_total
    assert m.save
    m = Movie.find m.id
    assert_equal 4, m.rating_average
    assert_equal 1, m.rating_count
    assert_equal 4, m.rating_total
    m.rate 6, users(:bill)
    m.rate 2, users(:sarah)
    assert_equal 4, m.rating_average
    assert_equal 3, m.rating_count
    assert_equal 12, m.rating_total
    assert_raise(ActiveRecord::Acts::Rated::RateError) { m.rate 6 }
    
    # Ratring with norating columns 
    b = books(:shogun)
    assert_raise(NoMethodError) { b.rating_total }
    check_average b, 3.75
    b.rate 10, Worker.find(users(:jane).id)
    check_average b, 5.5

    # Rating with no rater
    c = cars(:bug)
    check_average c, 4 
    assert_raise(ActiveRecord::Acts::Rated::RateError) { c.rate 10, users(:jill) }
    c.rate 10
    c.rate 10
    c.rate 10
    c.rate 10
    c.rate 10
    check_average c, 9

    # Ranged ratings
    f = Film.find :first, :order => 'title'
    assert_equal 'Crash', f.title
    assert_raise(ActiveRecord::Acts::Rated::RateError) { f.rate 0, users(:sarah) }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { f.rate 5.0001, users(:sarah) }
    f.rate 1, users(:sarah)
    f.rate 5, users(:jane)
    check_average f, 3 

    # rating with an external statistics table
    v = videos(:ten)
    rc = v.ratings.count
    assert_raise(NoMethodError) { v.rating_total }
    check_average v, 1 
    v.rate 9, users(:jane)
    check_average v, 3
    assert_equal rc, v.ratings.count
    v.rate 3, users(:jack)
    check_average v, 3
    assert_equal rc + 1, v.ratings.count
    t = Tape.find(videos(:fame).id)
    rc = t.ratings.count
    assert_raise(NoMethodError) { t.rating_total }
    check_average t, 5 
    t.rate 2, users(:jane)
    check_average t, 4
    assert_equal rc, t.ratings.count
    t.rate 8, users(:jack)
    check_average t, 5
    assert_equal rc + 1, t.ratings.count
    v = Video.new :title => 'Hair'
    v.save
    check_average v, 0
    v.rate 4, users(:bill)
    check_average v, 4
    t = Tape.new :title => 'Friends'
    t.save
    check_average t, 0
    t.rate 4, users(:bill)
    check_average t, 4
    t.rate 6, users(:jill)
    check_average t, 5
    
    # Rating with the wrong rater class or one that's not initialized
    assert_raise(ActiveRecord::Acts::Rated::RateError) { b.rate 10, users(:jane) }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { b.rate 10, 3 }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { b.rate 10, Worker.new }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { b.rate 10 }
  end

  def test_unrate
    # Regular one...
    m = movies(:gone_with_the_wind)
    check_average m, 4.33
    assert_raise(ActiveRecord::Acts::Rated::RateError) { m.unrate nil }
    m.unrate users(:john)
    m.unrate users(:bill)
    m.unrate users(:sarah)
    m.unrate users(:jane)
    m.unrate users(:jill)
    check_average m, 0
    m = Movie.new :title => 'King Kong'
    m.rate 4, users(:john)
    m.rate 4, users(:bill)
    assert m.new_record?
    assert_equal 4, m.rating_average
    assert_equal 2, m.rating_count
    assert_equal 8, m.rating_total
    assert m.save
    m = Movie.find m.id
    assert_equal 4, m.rating_average
    assert_equal 2, m.rating_count
    assert_equal 8, m.rating_total
    m.unrate users(:john)
    assert_equal 4, m.rating_average
    assert_equal 1, m.rating_count
    assert_equal 4, m.rating_total
    
    # Unrating with norating columns 
    b = books(:shogun)
    assert_raise(NoMethodError) { b.ratings[0].rating_total }
    check_average b, 3.75
    b.unrate Worker.find(users(:bill).id)
    check_average b, 4

    # Unrating with external stats table
    v = videos(:fields_of_dreams)
    check_average v, 3.2
    assert_raise(ActiveRecord::Acts::Rated::RateError) { v.unrate nil }
    v.unrate users(:john)
    v.unrate users(:bill)
    v.unrate users(:sarah)
    v.unrate users(:jane)
    v.unrate users(:jill)
    check_average v, 0
    v = Video.new :title => 'King Kong'
    assert v.new_record?
    assert v.save
    v = Video.find v.id
    v.rate 4, users(:john)
    v.rate 4, users(:bill)
    assert_equal 4, v.rating_average
    assert_equal 2, v.rated_count
    assert_equal 8, v.rated_total
    v.unrate users(:john)
    assert_equal 4, v.rating_average
    assert_equal 1, v.rated_count
    assert_equal 4, v.rated_total
    
    t = Tape.find(videos(:fields_of_dreams).id)
    check_average t, 3.2
    assert_raise(ActiveRecord::Acts::Rated::RateError) { t.unrate nil }
    t.unrate users(:john)
    t.unrate users(:bill)
    t.unrate users(:sarah)
    t.unrate users(:jane)
    t.unrate users(:jill)
    check_average t, 0
    t = Tape.new :title => 'Scream'
    assert t.save
    t.rate 4, users(:john)
    t.rate 6, users(:bill)
    t = Tape.find t.id
    assert_equal 5, t.rating_average
    assert_equal 2, t.rated_count
    assert_equal 10, t.rated_total
    t.unrate users(:john)
    assert_equal 6, t.rating_average
    assert_equal 1, t.rated_count
    assert_equal 6, t.rated_total
    
    # No unrating with no rater
    c = cars(:bug)
    assert_raise(ActiveRecord::Acts::Rated::RateError) { c.unrate users(:jill) }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { c.unrate nil }

    # Check unrater validity
    b = books(:shogun)
    assert_raise(ActiveRecord::Acts::Rated::RateError) { b.unrate users(:jane) }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { b.unrate 3 }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { b.unrate Worker.new }
  end
  
  def test_rated?
    [Car, Movie, Book, Video, Tape, Truck, Film].each do |c|
      # First check all the ones we have in the fixtures
      c.find(:all).each do |o|
        assert o.rated? if o.rated_count > 0
      end

      # Then create some new ones and test those as well
      o = c.new(:title => 'Test Title')
      assert o.save
      assert !o.rated?
      o.rate 4, Worker.find(users(:john).id) if [Book].include? c
      o.rate 4, users(:john) if [Movie, Video, Tape, Film].include? c
      o.rate 4 if [Car, Truck].include? c
      #o.reload
      assert o.rated?
    end
  end
  
  def test_rating_average
    m = movies(:gone_with_the_wind)
    check_average m, 4.33
    m = movies(:oz)
    check_average m, 5 
    m = movies(:crash)
    check_average m, 0 
    m.rate 3, users(:john)
    m.rate 5, users(:bill)
    check_average m, 4 
    m.rate 3, users(:bill)
    check_average m, 3 
    m.unrate users(:bill)
    check_average m, 3 
    
    c = cars(:camry)
    check_average c, 3 
    c = cars(:bug)
    check_average c, 4 
    c = cars(:expedition)
    check_average c, 0 
    c.rate 3
    c.rate 5
    check_average c, 4 
    c.rate 3
    check_average c, 3.66 
  end

  def test_count
    m = movies(:gone_with_the_wind)
    assert_equal 3, m.rated_count
    m.rate 4, users(:john)
    m.rate 4, users(:bill)
    m.rate 4, users(:sarah)
    m.rate 4, users(:jane)
    m.rate 4, users(:jill)
    assert_equal 5, m.rated_count
    
    c = cars(:expedition)
    assert_equal 0, c.rated_count
    c.rate 4
    c.rate 4
    c.rate 4
    c.rate 4
    c.rate 4
    assert_equal 5, c.rated_count

    b = books(:animal_farm)
    assert_equal 4, b.rated_count
    b.rate 4, Worker.find(users(:john).id)
    b.rate 4, Worker.find(users(:bill).id)
    b.rate 4, Worker.find(users(:sarah).id)
    b.rate 4, Worker.find(users(:jane).id)
    b.rate 4, Worker.find(users(:jill).id)
    assert_equal 5, b.rated_count
  end

  def test_total
    m = movies(:gone_with_the_wind)
    assert_equal 13, m.rated_total
    m.rate 4, users(:john)
    m.rate 4, users(:bill)
    m.rate 4, users(:sarah)
    m.rate 4, users(:jane)
    m.rate 4, users(:jill)
    assert_equal 20, m.rated_total
    
    c = cars(:expedition)
    assert_equal 0, c.rated_total
    c.rate 4
    c.rate 4
    c.rate 4
    c.rate 4
    c.rate 4
    assert_equal 20, c.rated_total

    b = books(:animal_farm)
    assert_equal 12, b.rated_total
    b.rate 4, Worker.find(users(:john).id)
    b.rate 4, Worker.find(users(:bill).id)
    b.rate 4, Worker.find(users(:sarah).id)
    b.rate 4, Worker.find(users(:jane).id)
    b.rate 4, Worker.find(users(:jill).id)
    assert_equal 20, b.rated_total
  end

  def test_rated_by?
    m = movies(:gone_with_the_wind)
    m.rate 4, users(:john)
    m.rate 4, users(:bill)
    m.rate 4, users(:sarah)
    m.rate 4, users(:jane)
    m.rate 4, users(:jill)
    m.unrate users(:jill)
    m.unrate users(:sarah)
    assert m.rated_by?(users(:john))
    assert m.rated_by?(users(:bill))
    assert m.rated_by?(users(:jane))
    assert !m.rated_by?(users(:jill))
    assert !m.rated_by?(users(:sarah))
    
    b = books(:animal_farm)
    b.rate 4, Worker.find(users(:john).id)
    b.rate 4, Worker.find(users(:bill).id)
    b.rate 4, Worker.find(users(:sarah).id)
    b.rate 4, Worker.find(users(:jane).id)
    b.rate 4, Worker.find(users(:jill).id)
    b.unrate Worker.find(users(:john).id)
    b.unrate Worker.find(users(:bill).id)
    assert !b.rated_by?(Worker.find(users(:john).id) )
    assert !b.rated_by?(Worker.find(users(:bill).id) )
    assert  b.rated_by?(Worker.find(users(:sarah).id))
    assert  b.rated_by?(Worker.find(users(:jane).id) )
    assert  b.rated_by?(Worker.find(users(:jill).id) )
  end
  
  def test_find_by_rating
    cs = Car.find_by_rating 0
    assert_equal 1, cs.size
    assert_equal 'Ford Expedition', cs[0].title
    cs = Car.find_by_rating 3
    assert_equal 1, cs.size
    assert_equal 'Toyota Camry', cs[0].title
    cs = Car.find_by_rating 3.5
    assert_equal 1, cs.size
    assert_equal 'VW Golf', cs[0].title
    cs = Car.find_by_rating 4, 0
    check_returned_array cs, ['VW Golf', 'Carrera', 'VW Bug'] 
    cs = Car.find_by_rating 3..4, 0
    check_returned_array cs, ['Toyota Camry', 'VW Golf', 'Carrera', 'VW Bug'] 
    cs = Car.find_by_rating 3..4
    check_returned_array cs, ['Toyota Camry', 'VW Golf', 'VW Bug'] 
    fs = Film.find_by_rating 1..4, 0
    check_returned_array fs, ["Rambo 3", "Gone With The Wind", "Phantom Menace"] 
    cs = Car.find_by_rating 3..4, 0, false
    check_returned_array cs, ['Toyota Camry', 'VW Golf', 'VW Bug'] 
    cs = Car.find_by_rating 3..4.5, 0, false
    check_returned_array cs, ['Toyota Camry', 'VW Golf', 'Carrera', 'VW Bug'] 
    fs = Film.find_by_rating 1..4, 0, false
    check_returned_array fs, ["Rambo 3", "Phantom Menace"] 
    ms = Movie.find_by_rating 5
    check_returned_array ms, ["The Wizard of Oz"] 
    bs = Book.find_by_rating 3..3.7
    check_returned_array bs, ["Alice in Wonderland", "Aminal Farm", "The Lord of the Rings", "Catch 22"] 
    bs = Book.find_by_rating 3..3.7, 0
    check_returned_array bs, ["Alice in Wonderland", "Aminal Farm", "The Lord of the Rings"] 
    bs = Book.find_by_rating 1..3, 0
    check_returned_array bs, ["Alice in Wonderland", "Aminal Farm", "The Lord of the Rings"] 
    bs = Book.find_by_rating 3, 0
    check_returned_array bs, ["Alice in Wonderland", "Aminal Farm", "The Lord of the Rings"] 

    bs = Book.find_by_rating 3..3.7, 0, false
    check_returned_array bs, ["Alice in Wonderland", "Aminal Farm", "The Lord of the Rings", "Catch 22"] 
    bs = Book.find_by_rating 1..3.3, 0, false
    check_returned_array bs, ["Alice in Wonderland", "Aminal Farm", "The Lord of the Rings"] 
    bs = Book.find_by_rating 3.75, 0, false
    check_returned_array bs, ["Shogun"] 
  end

  def test_find_rated_by
    assert_raise(ActiveRecord::Acts::Rated::RateError) { Car.find_rated_by 5 }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { Movie.find_rated_by nil }
    assert_raise(ActiveRecord::Acts::Rated::RateError) { Movie.find_rated_by 1 }
    ms = Movie.find_rated_by users(:john)
    check_returned_array ms, ["Gone With The Wind", "The Wizard of Oz", "Phantom Menace", "Rambo 3"] 
    ms = Movie.find_rated_by users(:jack)
    check_returned_array ms, []
    m = Movie.new :title => 'Borat'
    m.save
    m.rate 5, users(:jack)
    ms = Movie.find_rated_by users(:jack)
    check_returned_array ms, ["Borat"]
    bs = Book.find_rated_by Worker.find(users(:john).id)
    check_returned_array bs, ["The Lord of the Rings", "Alice in Wonderland", "Catch 22", "Aminal Farm"] 
    fs = Film.find_rated_by users(:john)
    check_returned_array fs, ["Gone With The Wind", "Phantom Menace", "The Wizard of Oz", "Rambo 3"] 
    f = Film.new :title => 'Kill Bill'
    f.save
    f.rate 4, users(:jill)
    fs = Film.find_rated_by users(:jill) 
    check_returned_array fs, ["Rambo 3", "Phantom Menace", "Kill Bill"] 
  end

  def test_associations
    assert User.new.respond_to?(:ratings)
    assert !Mechanic.new.respond_to?(:ratings)
    assert Book.new.respond_to?(:ratings)
    assert Book.new.respond_to?(:raters)
    assert Car.new.respond_to?(:ratings)
    assert !Car.new.respond_to?(:raters)
    assert Truck.new.respond_to?(:ratings)
    assert !Truck.new.respond_to?(:raters)
  end

  # This just test that the fixtures data makes sense
  def test_all_fixtures
    [Car, Movie, Book, Video, Tape, Truck, Film].each do |c|
      c.find(:all).each do |o| 
        check_average o, o.rating_average 
      end
    end
  end
  
  def check_average obj, value
    assert_equal (value * 100).to_i, (obj.rating_average * 100).to_i
    assert_equal (obj.ratings.average(:rating) * 100).to_i, (obj.rating_average * 100).to_i
  end
 
  def check_returned_array ar, expected_list
    names = ar.collect {|e| e.title }
    assert_equal expected_list.size, names.size
    assert_equal [], names - expected_list
  end
  
end


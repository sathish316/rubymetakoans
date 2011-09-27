require File.expand_path(File.dirname(__FILE__) + '/edgecase')

_triangle.rb_
# your previous triangle method should appear here
_triangle.rb_

class AboutTriangleProject2 < EdgeCase::Koan
  # The first assignment did not talk about how to handle errors.
  # Let's handle that part now.
  def test_illegal_triangles_throw_exceptions_zero_side
    assert_raise(TriangleError) do triangle(0, 0, 0) end
  end

  def test_illegal_triangles_throw_exceptions_negative_side
    assert_raise(TriangleError) do triangle(3, 4, -5) end
  end

  def test_illegal_triangles_throw_exceptions_one_side_too_long
    assert_raise(TriangleError) do triangle(1, 1, 3) end
  end

  def test_illegal_triangles_throw_exceptions_one_side_same_length_as_other_two
    assert_raise(TriangleError) do triangle(2, 4, 2) end
  end

  def test_equilateral_triangles_have_equal_sides
    assert_equal :equilateral, triangle(2, 2, 2)
    assert_equal :equilateral, triangle(10, 10, 10)
  end

  def test_isosceles_triangles_have_exactly_two_sides_equal
    assert_equal :isosceles, triangle(3, 4, 4)
    assert_equal :isosceles, triangle(4, 3, 4)
    assert_equal :isosceles, triangle(4, 4, 3)
    assert_equal :isosceles, triangle(10, 10, 2)
  end

  def test_scalene_triangles_have_no_equal_sides
    assert_equal :scalene, triangle(3, 4, 5)
    assert_equal :scalene, triangle(10, 11, 12)
    assert_equal :scalene, triangle(5, 4, 2)
  end
end


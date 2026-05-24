require "test_helper"

class FactTest < ActiveSupport::TestCase
  test "valid with a body" do
    fact = Fact.new(body: "An interesting fact.")
    assert fact.valid?
  end

  test "invalid without a body" do
    fact = Fact.new(body: nil)
    assert_not fact.valid?
    assert_includes fact.errors[:body], "can't be blank"
  end

  test "invalid with blank body" do
    fact = Fact.new(body: "   ")
    assert_not fact.valid?
    assert_includes fact.errors[:body], "can't be blank"
  end

  test "invalid with duplicate body" do
    Fact.create!(body: "Duplicate fact.")
    fact = Fact.new(body: "Duplicate fact.")
    assert_not fact.valid?
    assert_includes fact.errors[:body], "has already been taken"
  end

  test "invalid with body longer than 500 characters" do
    fact = Fact.new(body: "a" * 501)
    assert_not fact.valid?
    assert fact.errors[:body].any?
  end

  test "valid with body exactly 500 characters" do
    fact = Fact.new(body: "a" * 500)
    assert fact.valid?
  end
end

require "test_helper"

# Regression coverage for same-client concurrent requests.
#
# SQLite uses a single-writer model, so concurrent write access is serialized.
# The service uses with_lock (SELECT … FOR UPDATE via SQLite advisory mechanism)
# to ensure each concurrent caller advances the cursor atomically.
# This test verifies that when enough facts exist, two concurrent requests for
# the same client return distinct consecutive facts.
class ClientProgressionConcurrencyTest < ActionDispatch::IntegrationTest
  setup do
    Client.delete_all
    Fact.delete_all
  end

  test "concurrent requests for the same client return distinct consecutive facts" do
    client = Client.create!
    f1 = Fact.create!(body: "Concurrent Fact 1")
    f2 = Fact.create!(body: "Concurrent Fact 2")
    f3 = Fact.create!(body: "Concurrent Fact 3")

    results = []
    mutex = Mutex.new

    threads = 2.times.map do
      Thread.new do
        # Each thread uses its own resolver instance but the same persisted client
        c = Client.find(client.id)
        fact = ClientNextFactResolver.new(c).call
        mutex.synchronize { results << fact.id }
      end
    end
    threads.each(&:join)

    assert_equal 2, results.size, "Expected 2 results from concurrent requests"
    assert_equal 2, results.uniq.size,
      "Concurrent same-client requests must return distinct facts; got: #{results.inspect}"
  end

  test "sequential same-client requests never repeat a fact before wrap-around" do
    client = Client.create!
    facts = 5.times.map { |i| Fact.create!(body: "Seq Fact #{i + 1}") }

    seen_ids = facts.size.times.map do
      ClientNextFactResolver.new(client).call.id
    end

    assert_equal facts.map(&:id).sort, seen_ids.sort,
      "Each fact should be served exactly once before wrap-around"
  end
end

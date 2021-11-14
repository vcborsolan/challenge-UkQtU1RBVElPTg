require 'minitest/autorun'
require 'timeout'
class CustomerSuccessBalancing
   def initialize(customer_success, customers, customer_success_away)
    @customer_success = customer_success.sort_by {|cs| cs[:score]}
    @customers = customers
    @customer_success_away = customer_success_away
    @cs_attend_list = Hash.new {|h,k| h[k] = [] }
  end

  def execute
    filter_away_customers
    process_balance
    find_busiest_customer_success
  end

  private

  def process_balance
    @customers.each do |customer|
      cs = @customer_success.find { |cs| cs[:score] >= customer[:score] }
      @cs_attend_list[cs[:id]] << customer[:id] unless cs.nil?
    end
  end

  def find_busiest_customer_success
    attend_list = @cs_attend_list
    @max_customers = 0
    @busiest_cs_id = 0
    @current_attended_count = 0

    attend_list.each do |customer_success, customers|
      @current_attended_count = customers.count
      if overflowed?
        @max_customers = @current_attended_count
        @busiest_cs_id = customer_success
      elsif draw?
        @busiest_cs_id = 0
      end
    end

    return @busiest_cs_id
  end

  def draw?
    @current_attended_count == @max_customers
  end

  def overflowed?
    @current_attended_count > @max_customers
  end

  def filter_away_customers
    @customer_success.reject! { |customer| @customer_success_away.include?(customer[:id]) }
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    css = [{ id: 1, score: 60 }, { id: 2, score: 20 }, { id: 3, score: 95 }, { id: 4, score: 75 }]
    customers = [{ id: 1, score: 90 }, { id: 2, score: 20 }, { id: 3, score: 70 }, { id: 4, score: 40 }, { id: 5, score: 60 }, { id: 6, score: 10}]

    balancer = CustomerSuccessBalancing.new(css, customers, [2, 4])
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    css = array_to_map([11, 21, 31, 3, 4, 5])
    customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CustomerSuccessBalancing.new(css, customers, [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    customer_success = (1..999).to_a
    customers = Array.new(10000, 998)

    balancer = CustomerSuccessBalancing.new(array_to_map(customer_success), array_to_map(customers), [999])

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(array_to_map([1, 2, 3, 4, 5, 6]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 2, 3, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [1, 3, 2])
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [4, 5, 6])
    assert_equal 3, balancer.execute
  end

  def array_to_map(arr)
    out = []
    arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
    out
  end
end

Minitest.run
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
require 'spec_helper'
require 'customer_success_balancing'
require 'timeout'

describe CustomerSuccessBalancing do
    it 'first scenario' do
        css = [{ id: 1, score: 60 }, { id: 2, score: 20 }, { id: 3, score: 95 }, { id: 4, score: 75 }]
        customers = [{ id: 1, score: 90 }, { id: 2, score: 20 }, { id: 3, score: 70 }, { id: 4, score: 40 }, { id: 5, score: 60 }, { id: 6, score: 10}]
  
        balancer = CustomerSuccessBalancing.new(css, customers, [2, 4])
        expect(balancer.execute).to eq(1)
    end

    it 'second scenario' do
        css = array_to_map([11, 21, 31, 3, 4, 5])
        customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
        balancer = CustomerSuccessBalancing.new(css, customers, [])
        expect(balancer.execute).to eq(0)
    end

    it 'third scenario' do
        customer_success = (1..999).to_a
        customers = Array.new(10000, 998)

        balancer = CustomerSuccessBalancing.new(array_to_map(customer_success), array_to_map(customers), [999])

        result = Timeout.timeout(1.0) { balancer.execute }
        expect(result).to eq(998)
    end

    it 'fourth scenario' do
        balancer = CustomerSuccessBalancing.new(array_to_map([1, 2, 3, 4, 5, 6]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
        expect(balancer.execute).to eq(0)
    end
  
    it 'fifth scenario' do
        balancer = CustomerSuccessBalancing.new(array_to_map([100, 2, 3, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
        expect(balancer.execute).to eq(1)
    end
    
    it 'sixth scenario' do
        balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [1, 3, 2])
        expect(balancer.execute).to eq(0)
    end

    it 'seventh scenario' do
        balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [4, 5, 6])

        expect(balancer.execute).to eq(3)
    end

    def array_to_map(arr)
      out = []
      arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
      out
    end
end

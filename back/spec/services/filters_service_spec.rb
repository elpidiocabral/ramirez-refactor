require 'rails_helper'

describe FiltersService do
  context 'Matching Params' do
    it 'Returns photographer with no other filters' do
      filter = FiltersService.instance.matching_params({})

      expect(filter).to eq({ photographer: true, :specialization.exists => true })
    end
  end

  context 'Location Params' do
    it 'Returns correct location hash' do
      filter = FiltersService.instance.location_params('CE')

      expect(filter).to eq([{ city: 'CE' }, { state: 'CE' }])
    end

    it 'Returns empty hash when empty location sended' do
      filter = FiltersService.instance.location_params('')

      expect(filter).to eq([])
    end
  end

  context 'Order Params' do 
    it 'Returns correct order_by hash' do
      filter = FiltersService.instance.order_params('likes')

      expect(filter).to eq({ likes: :desc })
    end

    it 'Returns empty hash when empty order_by criteria sended' do
      filter = FiltersService.instance.order_params('')

      expect(filter).to eq({})
    end
  end

  context 'Price Params' do 
    it 'Returns correct price hash with min and max' do
      filter = FiltersService.instance.price_params({ min_price: 10, max_price: 100 })

      expect(filter).to eq({ :services_price.elem_match => { :$gte => 10, :$lte => 100 } })
    end

    it 'Returns correct price hash with only min' do
      filter = FiltersService.instance.price_params({ min_price: 10 })

      expect(filter).to eq({ :services_price.elem_match => { :$gte => 10 } })
    end

    it 'Returns correct price hash with only max' do
      filter = FiltersService.instance.price_params({ max_price: 100 })

      expect(filter).to eq({ :services_price.elem_match => { :$lte => 100 } })
    end

    it 'Returns empty hash when params are not sended' do
      filter = FiltersService.instance.price_params({})

      expect(filter).to eq({})
    end
  end

  context 'Check Pagination' do
    it 'Return true if page is nil' do
      filter = FiltersService.instance.check_pagination(nil)

      expect(filter).to eq(true)
    end

    it 'Return true if page is an integer' do
      filter = FiltersService.instance.check_pagination('200')
      filter2 = FiltersService.instance.check_pagination(300)

      expect(filter).to eq(true)
      expect(filter2).to eq(true)
    end
  end
end

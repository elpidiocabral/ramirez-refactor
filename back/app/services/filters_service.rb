class FiltersService
  include Singleton

  def matching_params(params)
    new_hash = { photographer: true }
    params.each_pair { |k, v| new_hash[k.to_sym] = v if check_param(k, v) }
    new_hash[:name] = /.*#{params[:name]}.*/ unless !params.key?(:name) || params[:name] == ''
    new_hash
  end
  
  def location_params(location)
    locate = []
    locate = [{ city: location }, { state: location }] unless location.nil? || location == ''
    locate
  end

  def order_params(order_by)
    order = {}
    order = { order_by.to_sym => :desc } if order_by != '' && %w[likes views price].include?(order_by)
    order
  end

  def price_params(params)
    min_price = (params[:min_price].nil? ? nil : params[:min_price].to_f)
    max_price = (params[:max_price].nil? ? nil : params[:max_price].to_f)


    return {} if min_price.nil? && max_price.nil?
    return { :services_price.elem_match => { :$lte => max_price } } if min_price.nil?
    return { :services_price.elem_match => { :$gte => min_price } } if max_price.nil?

    { :services_price.elem_match => { :$gte => min_price, :$lte => max_price } }
  end

  def check_pagination(page)
    page.nil? || page.is_a?(Integer) || (page.is_a?(String) && !Integer(page).nil?)
  end

  def check_param(key, value)
    key = key.to_sym
    condition1 = %i[name specialization].include?(key)
    condition2 = value != "" && !value.nil?

    condition1 && condition2
  end

  private_class_method :check_param
end

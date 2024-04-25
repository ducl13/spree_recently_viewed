class RecentlyViewedProductsService
  attr_reader :spree_current_user, :product_id, :cookies

  def initialize(spree_current_user, product_id = nil, cookies)
    @spree_current_user = spree_current_user
    @product_id = product_id
    @cookies = cookies
  end

  def track_viewed_product
    if spree_current_user.present?
      track_for_logged_in_user
    else
      track_for_guest_user
    end
  end

  def recently_viewed_products
    if spree_current_user.present? && spree_current_user.viewed_products.present?
      product_ids = spree_current_user.viewed_products.pluck(:product_id)
      Spree::Product.where(id: product_ids).where.not(id: @product_id)
    elsif cached_recently_viewed_products_ids.present?
      Spree::Product.where(id: cached_recently_viewed_products_ids).where.not(id: @product_id)
    else
      []
    end
  end

  private

  def track_for_logged_in_user
    ActiveRecord::Base.connected_to(role: :writing) do
      viewed_product = Spree::ViewedProduct.find_or_initialize_by(user_id: spree_current_user.id, product_id: product_id)
      viewed_product.save
    end
  end

  def track_for_guest_user
    recently_viewed_products = (cookies['recently_viewed_products'] || '').split(', ')
    recently_viewed_products.delete(product_id)
    recently_viewed_products << product_id unless recently_viewed_products.include?(product_id)
    cookies['recently_viewed_products'] = recently_viewed_products.join(', ')
  end

  def cached_recently_viewed_products_ids
    (cookies['recently_viewed_products'] || '').split(', ')
  end
end

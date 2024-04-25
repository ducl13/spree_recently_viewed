module Spree::ProductsControllerDecorator
  def self.prepended(base)
    base.include Spree::RecentlyViewedProductsHelper
    base.helper_method [:cached_recently_viewed_products, :cached_recently_viewed_products_ids]
    base.before_action :set_current_order, except: :recently_viewed
    base.before_action :save_recently_viewed, only: :recently_viewed
  end

  def recently_viewed
    render 'spree/products/recently_viewed', layout: false
  end

  private

  def save_recently_viewed
    product_id = params[:product_id]
    return unless product_id.present?

    recently_viewed_service = RecentlyViewedProductsService.new(spree_current_user, product_id, cookies)
    recently_viewed_service.track_viewed_product
    @recently_viewed_products = recently_viewed_service.recently_viewed_products

  end
end

Spree::ProductsController.prepend Spree::ProductsControllerDecorator

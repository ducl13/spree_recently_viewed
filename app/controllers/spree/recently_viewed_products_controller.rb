module Spree
  class RecentlyViewedProductsController < Spree::StoreController
    include Spree::FrontendHelper
    include Spree::CacheHelper
    helper 'spree/products'

    before_action :load_recently_viewed_products, only: [:index, :clear_all, :home_products]

    def index
      if params[:sort_by].present? && params[:sort_by] == "name-z-a"
        recently_viewed_products = @recently_viewed_products.order(name: :desc)
      else
        recently_viewed_products = @recently_viewed_products.order(name: :asc)
      end

      if recently_viewed_products.present?
        if (browser.device.mobile? || browser.device.tablet?)
          @pagy, @recently_viewed_products = pagy_array(recently_viewed_products, size: Pagy::DEFAULT[:size_mobile])
        else
          @pagy, @recently_viewed_products = pagy_array(recently_viewed_products)
        end
      end
    end

    def home_products
      render 'spree/products/home_products', layout: false
    end

    def clear_all
      ActiveRecord::Base.connected_to(role: :writing) do
        @recently_viewed_products.delete_all
      end
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.js
      end
    end

    def load_recently_viewed_products
      recently_viewed_service = RecentlyViewedProductsService.new(spree_current_user, nil, cookies)
      @recently_viewed_products = recently_viewed_service.recently_viewed_products
    end

  end
end

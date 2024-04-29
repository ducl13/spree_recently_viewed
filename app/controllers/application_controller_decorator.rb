module ApplicationControllerDecorator
  def self.prepended(base)
    base.before_action :transfer_viewed_products_from_cookies, if: -> { spree_current_user.present? && cookies['recently_viewed_products'].present? }
  end

  private

  def transfer_viewed_products_from_cookies
    recently_viewed_products = cookies['recently_viewed_products'].split(', ')

    # Get user's ViewedProduct records
    user_viewed_products = spree_current_user.viewed_products

    # Add viewed products from cookies to user's ViewedProduct records
    recently_viewed_products.each do |product_id|
      # Skip if the product is already viewed by the user
      next if user_viewed_products.exists?(product_id: product_id.to_i)

      # Create a new ViewedProduct record for the user
      ActiveRecord::Base.connected_to(role: :writing) do
        spree_current_user.viewed_products.create(product_id: product_id.to_i)
      end
    end

    # Clear cookies after transferring viewed products
    cookies.delete('recently_viewed_products')

  end
end

ApplicationController.prepend ApplicationControllerDecorator

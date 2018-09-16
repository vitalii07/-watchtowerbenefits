module Api::V1
  class ProductsController < BaseController
    before_action :load_document, only: [:index, :create]

    def index
      @products = @document.products.includes(:product_type, product_classes: [:dynamic_values])
      render json: @products
    end

    def create
      @product = @document.products.create(product_params)
      render json: @product, status: :created
    end

    def show
      @product = Product.includes(:product_type, product_classes: [:dynamic_values]).find params[:id]
      render json: @product
    end

    def destroy
      @product = Product.find params[:id]
      @product.destroy

      head :ok
    end

    def match_current
      @product = Product.find(params[:id])
      @product.match_product(@product.correspondent_inforce_product, params[:attribute_id_filter])
      @product = Product.includes(:product_type, product_classes: [:dynamic_values]).find(params[:id])
      render json: @product
    end

    private

    def load_document
      @document = Document.find params[:document_id]
    end

    def product_params
      params.require(:product).permit(:product_type_id, :contributory)
    end
  end
end

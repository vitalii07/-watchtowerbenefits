module Api::V1
  class EmployersController < BaseController
    def index
      @employers = Employer.all
      render json: @employers, each_serializer: Api::V1::EmployerSerializer
    end

    def show
      @employer = Employer.includes(employer_includes).find(params[:id])
      render json: @employer
    end

    private

    def employer_includes
      {
        user: [
          projects: [
            documents: [
              :carrier, :sources,
              products: [:product_type, product_classes: [:dynamic_values]]
            ]
          ]
        ]
      }
    end
  end
end

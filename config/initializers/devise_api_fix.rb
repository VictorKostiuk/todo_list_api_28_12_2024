Rails.application.config.to_prepare do
  # Override Devise responders to avoid respond_to errors in API mode
  module DeviseResponders
    def respond_with(resource, _opts = {})
      if resource.errors.empty?
        render json: { message: 'Success', resource: resource }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def respond_to_on_destroy
      head :no_content
    end
  end

  # Prepend the module to Devise::SessionsController
  Devise::SessionsController.prepend DeviseResponders
end

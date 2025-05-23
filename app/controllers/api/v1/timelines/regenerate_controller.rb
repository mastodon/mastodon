class Api::V1::Timelines::RegenerateController < Api::BaseController
    def create
        regenerate
    end

    def regenerate
        # Accept account_id as a param, fallback to current_user if not provided
        account_id = params[:account_id]

        if account_id.nil?
        render json: { error: "Account ID is required" }, status: :bad_request and return
        end 

        account = Account.find_by(id: account_id)
        if account.nil?
            render json: { error: "Account not found" }, status: :not_found and return
        end

        user = account.user
        if user.nil?
            render json: { error: "No local user for this account" }, status: :unprocessable_entity and return
        end

        # unless current_user.admin? || current_user.account.id == account.id
        #   render json: { error: "Forbidden" }, status: :forbidden and return
        # end

        user.regenerate_feed_override!
        render json: { message: "Feed regeneration started for account #{account.id}" }, status: :accepted
    end
end
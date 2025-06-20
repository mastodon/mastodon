class Api::V1::Timelines::CleanFeedsController < Api::BaseController
    # POST /api/v1/timelines/clean_feeds
    def create
        clean_feeds
    end

    def clean_feeds
        feed_type = params[:feed_type]
        ids       = params[:ids]

        if feed_type.nil?
            render json: { error: "Feed type is required" }, status: :bad_request and return
        end

        if ids.nil?
            render json: { error: "IDs are required" }, status: :bad_request and return
        end

        unless ids.is_a?(Array)
            render json: { error: "IDs must be an array" }, status: :bad_request and return
        end

        clean_ids = ids.map(&:to_i)

        # Optional: restrict to valid feed types
        # valid_types = %w[home list]
        # unless valid_types.include?(feed_type)
        #     render json: { error: "Invalid feed type: #{feed_type}" }, status: :bad_request and return
        # end

        # Optional: enforce permissions
        # unless current_user.admin?
        #   render json: { error: "Forbidden" }, status: :forbidden and return
        # end

        FeedManager.instance.clean_feeds!(feed_type.to_sym, clean_ids)
        render json: { message: "Cleaned #{feed_type} feeds for IDs: #{clean_ids.join(', ')}" }, status: :accepted
    end
end

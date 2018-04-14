module ApiV1StatusesControllerPatch
    def create
      status = Nyaaaan.convert_toot(status_params[:status])
      @status = PostStatusService.new.call(current_user.account,
                                           status,
                                           status_params[:in_reply_to_id].blank? ? nil : Status.find(status_params[:in_reply_to_id]),
                                           media_ids: status_params[:media_ids],
                                           sensitive: status_params[:sensitive],
                                           spoiler_text: status_params[:spoiler_text],
                                           visibility: status_params[:visibility],
                                           application: doorkeeper_token.application,
                                           idempotency: request.headers['Idempotency-Key'])
  
      render json: @status, serializer: REST::StatusSerializer
    end
  end

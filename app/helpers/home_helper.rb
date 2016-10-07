module HomeHelper
  def default_props
    {
      token: @token,

      account: render(file: 'api/v1/accounts/show', locals: { account: current_user.account }, formats: :json),

      timelines: {
        home: render(file: 'api/v1/statuses/index', locals: { statuses: @home }, formats: :json),
        mentions: render(file: 'api/v1/statuses/index', locals: { statuses: @mentions }, formats: :json)
      }
    }
  end
end

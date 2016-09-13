module HomeHelper
  def default_props
    {
      token: @token,

      account: render(file: 'api/accounts/show', locals: { account: current_user.account }, formats: :json),

      timelines: {
        home: render(file: 'api/statuses/home', locals: { statuses: @home }, formats: :json),
        mentions: render(file: 'api/statuses/mentions', locals: { statuses: @mentions }, formats: :json)
      }
    }
  end
end

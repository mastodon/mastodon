# frozen_string_literal: true

module HomeHelper
  def default_props
    {
      token: @token,
      account: render(file: 'api/v1/accounts/show', locals: { account: current_user.account }, formats: :json),
    }
  end
end

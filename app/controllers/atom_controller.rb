class AtomController < ApplicationController
  before_filter :set_format

  def user_stream
    @account = Account.find_by!(id: params[:id], domain: nil)
  end

  private

  def set_format
    request.format = 'xml'
    response.headers['Content-Type'] = 'application/atom+xml'
  end
end

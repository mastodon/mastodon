# frozen_string_literal: true

class PostStatusUpdatedWithVisibilityService < BaseService
  # Post a text status update with visibility
  # @param [User] user User from which to post
  # @param [Hash] options
  # @option [String] :text Message
  # @option [String] :visibility
  # @option [String] :spoiler_text
  # @return [String, String, String] text, visibility, spoiler_text
  def call(user, options = {})
    @account      = user
    @options      = options
    @text         = @options[:text]
    @visibility   = @options[:visibility]
    @spoiler_text = @options[:spoiler_text]

    # フロントから受け取った公開範囲：にゃーんのつぶやきかどうかをチェックし、にゃーんの場合は置き換え
    if @visibility == 'nyan'
      @text = "にゃーん" 
      @visibility = 'public'
  
      # CWのタイトルがあった場合は「にゃーん」をセット
      if @spoiler_text != ''
        @spoiler_text = "にゃーん"
      end
    end
  
    # フロントから受け取った公開範囲：ポートフォリオの呟きかどうかをチェックし、
    # ポートフォリオの場合は公開範囲を置き換えた上でハッシュタグを追加する
    if @visibility == 'portfolio'
      @text = "#{@text}\n#CreatodonFolio\n"
      @visibility = 'public'
  
      # 公開範囲：ポートフォリオ用のデフォルトハッシュタグを利用するフラグが有効になっている場合はデフォルトハッシュタグを追加する
      if user.setting_portfolio_default_hashtag_flag
        @text = "#{@text}#{user.setting_portfolio_default_hashtag}\n"
      end
    end
  
    return @text, @visibility, @spoiler_text
  end
end
  
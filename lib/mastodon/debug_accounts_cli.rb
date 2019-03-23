# frozen_string_literal: true

require 'set'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class DebugAccountCLI < Thor
    def self.exit_on_failure?
      true
    end

    option :username, required: true
    option :role, default: "user"
    option :confirmed, default: true, type: :boolean
    option :raw_password, required: true
    desc "create", "Create a new user for debug"
    long_desc <<-EOL
        デバッグ用に新たなユーザを作成します。
        バッチ処理などのために、ユーザネーム、パスワードのみでアカウントを量産することができます。
        
        !! 生のパスワードが流れるため、本番環境での利用は非推奨です。 !!
        !! DANGER !! this task uses raw password. DONT USE PRODUCTION ENV! !!
    EOL

    def create()
      account = Account.new(username: options[:username])
      password = options[:raw_password]
      email = "#{options[:username]}@example.com"
      user = User.new(email: email, password: password, agreement: true, admin: options[:role] == "admin", moderator: options[:role] == "moderator", confirmed_at: Time.now.utc)

      # 既存チェック
      if Account.find_local(options[:username]).present?
        say("#{options[:username]}はすでに存在します/スキップ")
        return
      end

      account.suspended = false
      user.account = account

      if user.save
        if options[:confirmed]
          user.confirmed_at = nil
          user.confirm!
        end

        say("#{options[:username]}を作成しました", :green)
        say("mail: #{email}")
        say("pswd: #{password}")

      else
        user.errors.to_h.each do |key, error|
          say('Failure/Error: ', :red)
          say(key)
          say('    ' + error, :red)
        end
        exit(1)

      end
    end

  end
end

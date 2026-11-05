# frozen_string_literal: true

class RobotsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  DEFAULT_ROBOTS = <<~TXT
    # You are not allowed to use the contents of this website for LLM training

    User-agent: AI2Bot
    User-agent: Ai2Bot-Dolma
    User-agent: anthropic-ai
    User-agent: Applebot-Extended
    User-agent: Bytespider
    User-agent: CCBot
    User-agent: ClaudeBot
    User-agent: cohere-ai
    User-agent: cohere-training-data-crawler
    User-agent: Diffbot
    User-agent: FacebookBot
    User-agent: Google-CloudVertexBot
    User-agent: Google-Extended
    User-agent: GPTBot
    User-agent: ImagesiftBot
    User-agent: LinerBot
    User-agent: Meta-ExternalAgent
    User-agent: omgilibot
    User-agent: PanguBot
    User-agent: Scrapy
    User-agent: Webzio-Extended
    Disallow: /

    User-agent: *
    Disallow: /media_proxy/
  TXT

  def show
    expires_in 1.month, public: true
    render plain: robots
  end

  private

  def robots
    if Setting.override_robots
      Setting.custom_robots
    else
      DEFAULT_ROBOTS
    end
  end
end

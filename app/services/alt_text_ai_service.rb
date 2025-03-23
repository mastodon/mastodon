# frozen_string_literal: true

class AltTextAiService
  include Singleton

  def initialize
    @prompt = ENV.fetch('ALT_TEXT_AI_PROMPT', 'Describe this image in detail for someone who cannot see it.')
    @api_base = ENV.fetch('ALT_TEXT_AI_API_BASE', nil)
    @api_key = ENV.fetch('ALT_TEXT_AI_API_KEY', nil)
    @model = ENV.fetch('ALT_TEXT_AI_MODEL', 'google/gemma-3-4b-it:free')
  end

  def generate_alt_text(media_attachment)
    return nil unless Mastodon::Feature.alt_text_ai_enabled?
    return nil unless media_attachment.image?
    return nil unless media_attachment.file.exists?

    image_data = encode_image(media_attachment.file.path(:original))
    response = make_openai_request(image_data)
    
    parse_response(response)
  rescue => e
    Rails.logger.error "Error generating alt text with AI: #{e}"
    nil
  end

  private

  def encode_image(file_path)
    Base64.strict_encode64(File.read(file_path))
  end

  def make_openai_request(image_data)
    #uri = URI.parse(@api_base + "/chat/completions")
    uri = URI.parse(@api_base)
    uri.path = File.join(uri.path, 'chat/completions')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}" if @api_key.present?
    
    request.body = {
      model: @model,
      messages: [
        {
          role: 'system',
          content: @prompt
        },
        {
          role: 'user',
          content: [
            {
              type: 'image_url',
              image_url: {
                url: "data:image/jpeg;base64,#{image_data}"
              }
            }
          ]
        }
      ],
      max_tokens: 300
    }.to_json
    
    response = http.request(request)
    Rails.logger.error "it return #{response.body}"
    JSON.parse(response.body)
  end

  def parse_response(response)
    return nil unless response['choices'] && response['choices'].first && response['choices'].first['message']
    
    response['choices'].first['message']['content'].strip
  end
end
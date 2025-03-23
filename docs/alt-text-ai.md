# AI-Generated Alt Text for Images

Mastodon now supports automatically generating alternative (alt) text for images using OpenAI's API. This feature helps improve accessibility by providing descriptions for images that might otherwise lack them.

## Configuration

This feature is optional and disabled by default. To enable it, you need to set the following environment variables:

```bash
# The system prompt to send to the OpenAI API
ALT_TEXT_AI_PROMPT="Describe this image in detail for someone who cannot see it. Focus on the main subjects, actions, and important details. Be concise but thorough."

# The base URL for the OpenAI-compatible API
ALT_TEXT_AI_API_BASE="https://openrouter.ai/api/v1"

# The API key for authentication
ALT_TEXT_AI_API_KEY="your-api-key-here"

# The AI model to use (optional, defaults to google/gemma-3-4b-it)
ALT_TEXT_AI_MODEL="google/gemma-3-4b-it"
```

The `ALT_TEXT_AI_PROMPT`, `ALT_TEXT_AI_API_BASE`, and `ALT_TEXT_AI_API_KEY` environment variables must be set for the feature to be enabled. If any of these is missing, the feature will be completely hidden from the user interface. The `ALT_TEXT_AI_MODEL` variable is optional and defaults to "google/gemma-3-4b-it", which is available for free on OpenRouter at the time of creating this documentation.

## How It Works

When enabled, a "Generate with AI" button appears in the alt text modal when uploading or editing an image. Clicking this button sends the image to the configured OpenAI API endpoint using the GPT-4 Vision model, along with the system prompt specified in the environment variable.

The generated description is then automatically populated in the alt text field, where users can review and edit it before saving.

## Privacy and Security

- Image data is only sent to the external API if the instance admin has explicitly enabled this feature by setting both required environment variables.
- The feature is designed to work with OpenAI's API, but it can be configured to work with any compatible API endpoint that follows the same request/response format.
- Users should always review the generated alt text before publishing to ensure it accurately describes the image.
## Customization

You can customize the system prompt by changing the `ALT_TEXT_AI_PROMPT` environment variable. A good prompt should instruct the AI to focus on the most important aspects of the image and provide clear, concise descriptions suitable for screen readers.
## Using OpenRouter

The default configuration uses [OpenRouter](https://openrouter.ai/) as the API provider, which offers access to various AI models including the default "google/gemma-3-4b-it" model that is free to use (as of the time this documentation was created). To use OpenRouter:

1. Sign up for an account at [OpenRouter](https://openrouter.ai/)
2. Get your API key from the dashboard
3. Set `ALT_TEXT_AI_API_BASE` to "https://openrouter.ai/api/v1"
4. Set `ALT_TEXT_AI_API_KEY` to your OpenRouter API key

OpenRouter provides a cost-effective way to access various AI models without having to set up separate accounts with each provider.
OpenRouter provides a cost-effective way to access various AI models without having to set up separate accounts with each provider.
You can customize the system prompt by changing the `ALT_TEXT_AI_PROMPT` environment variable. A good prompt should instruct the AI to focus on the most important aspects of the image and provide clear, concise descriptions suitable for screen readers.

## Troubleshooting

If the "Generate with AI" button doesn't appear:
- Verify that both environment variables are set correctly
- Check that the image is in a supported format (JPEG, PNG, GIF, etc.)
- Ensure your server can connect to the specified API endpoint

If the generated descriptions are poor quality:
- Try adjusting the system prompt to be more specific about what details to include or exclude
- Consider using a different API endpoint that might provide better results for your use case
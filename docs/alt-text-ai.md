# AI-Generated Alt Text for Images

Mastodon now supports automatically generating alternative (alt) text for images using OpenAI's API. This feature helps improve accessibility by providing descriptions for images that might otherwise lack them.

## Configuration

This feature is optional and disabled by default. To enable it, you need to set the following environment variables:

```bash
# The system prompt to send to the OpenAI API
ALT_TEXT_AI_PROMPT="Describe this image in detail for someone who cannot see it. Focus on the main subjects, actions, and important details. Be concise but thorough."

# The base URL for the OpenAI API
ALT_TEXT_AI_API_BASE="https://api.openai.com/v1/chat/completions"

# The AI model to use (optional, defaults to gpt-4-vision-preview)
ALT_TEXT_AI_MODEL="gpt-4-vision-preview"
```

The `ALT_TEXT_AI_PROMPT` and `ALT_TEXT_AI_API_BASE` environment variables must be set for the feature to be enabled. If either is missing, the feature will be completely hidden from the user interface. The `ALT_TEXT_AI_MODEL` variable is optional and defaults to "gpt-4-vision-preview".

## How It Works

When enabled, a "Generate with AI" button appears in the alt text modal when uploading or editing an image. Clicking this button sends the image to the configured OpenAI API endpoint using the GPT-4 Vision model, along with the system prompt specified in the environment variable.

The generated description is then automatically populated in the alt text field, where users can review and edit it before saving.

## Privacy and Security

- Image data is only sent to the external API if the instance admin has explicitly enabled this feature by setting both required environment variables.
- The feature is designed to work with OpenAI's API, but it can be configured to work with any compatible API endpoint that follows the same request/response format.
- Users should always review the generated alt text before publishing to ensure it accurately describes the image.

## Customization

You can customize the system prompt by changing the `ALT_TEXT_AI_PROMPT` environment variable. A good prompt should instruct the AI to focus on the most important aspects of the image and provide clear, concise descriptions suitable for screen readers.

## Troubleshooting

If the "Generate with AI" button doesn't appear:
- Verify that both environment variables are set correctly
- Check that the image is in a supported format (JPEG, PNG, GIF, etc.)
- Ensure your server can connect to the specified API endpoint

If the generated descriptions are poor quality:
- Try adjusting the system prompt to be more specific about what details to include or exclude
- Consider using a different API endpoint that might provide better results for your use case
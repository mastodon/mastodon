# Log cache errors with Rail's logger
# This used to be the default in old Rails versions: https://github.com/rails/rails/commit/7fcf8590e788cef8b64cc266f75931c418902ca9#diff-f0748f0be8a653eea13369ebb1cadabcad71ede7cfaf20282447e64329817befL86
Rails.cache.logger = Rails.logger

# see https://keybase.io/docs/proof_integration_guide#1-config

JSON.pretty_generate({
  "version": 1,
  "domain": @my_domain,
  "display_name": @domain_display,
  "username": {
    "re": @username_re,
    "min": 1,
    "max": 30
  },

  # Your brand logo will appear in various places around the Keybase app.
  # Assets will be rehosted by Keybase, so do let us know about updates.
  "brand_color": @brand_color,
  "logo": {
    # A full-black monochrome SVG. Should look good at 16px square. Expand all texts and strokes to shapes.
    "svg_black": @svg_black,
    # A full color SVG. Should look good at 32px square. Expand all texts and strokes to shapes.
    "svg_full": @svg_full
  },
  "description": @description,

  "prefill_url": @prefill_url,
  "profile_url": @profile_url,
  "check_url": @check_url,
  "check_path": ["signatures"],
  "avatar_path": ["avatar"],

  # list of contacts for Keybase in case of issues
  "contact": @contacts
})

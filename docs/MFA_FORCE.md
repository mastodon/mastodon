# MFA Force Feature

## Overview

The MFA Force feature allows administrators to require all users to enable two-factor authentication (2FA) before they can access the platform. This is useful for organizations with strict security policies.

## Configuration

### Environment Variable

To enable MFA forcing, set the following environment variable:

```bash
MFA_FORCE=true
```

### Docker Compose

Add the environment variable to your `.env.production` file:

```env
MFA_FORCE=true
```

Or add it directly to your `docker-compose.yml`:

```yaml
services:
  web:
    environment:
      - MFA_FORCE=true
    # ... other configuration
```

## Behavior

When `MFA_FORCE=true` is set:

1. **After Login**: Users who don't have 2FA enabled will be automatically redirected to the 2FA setup page (`/settings/otp_authentication`)

2. **Message Display**: A warning message (using Mastodon's flash message system) is shown explaining that 2FA is required due to security policies

3. **Access Restriction**: Users cannot access most parts of the platform until they configure 2FA

4. **Allowed Pages**: Users can still access:

   - 2FA setup pages (`/settings/otp_authentication`)
   - 2FA confirmation pages (`/settings/two_factor_authentication/confirmation`)
   - Account settings (`/settings/profile`)
   - Logout (`/auth/sign_out`)
   - Setup pages for unconfirmed users (`/auth/setup`)

5. **User Experience**: A clear message explains why 2FA is required and guides users through the setup process

## User Interface

### Message Display

When MFA forcing is enabled, users will see:

- **Warning Message**: "The administrator of this site has configured as mandatory that users enable two-factor authentication due to security policies. Please configure your two-factor authentication to continue using the platform."

- **Flash Message**: Uses Mastodon's built-in flash message system with warning styling

- **Visual Indicator**: A prominent notice on the 2FA setup page with a security icon

### Multi-language Support

The feature includes translations for:

- English
- Spanish
- And other supported languages

## Implementation Details

### Files Modified

1. **`app/controllers/concerns/mfa_force_concern.rb`**: Core logic for checking MFA requirements
2. **`app/controllers/application_controller.rb`**: Includes the MFA force concern
3. **`app/helpers/flashes_helper.rb`**: Updated to support warning flash messages
4. **`app/views/settings/two_factor_authentication/otp_authentication/show.html.haml`**: Updated to show the forced MFA message
5. **`app/javascript/styles/mastodon/forms.scss`**: Added styles for the MFA force notice
6. **`config/locales/en.yml`**: English translations
7. **`config/locales/es.yml`**: Spanish translations

### Testing

Run the tests to verify the functionality:

```bash
bundle exec rspec spec/controllers/concerns/mfa_force_concern_spec.rb
```

## Security Considerations

- **Existing Users**: Users who already have 2FA enabled are not affected
- **New Users**: All new users must configure 2FA before accessing the platform
- **Admin Access**: Administrators are also subject to this requirement
- **Graceful Degradation**: If the environment variable is not set, the feature is disabled

## Troubleshooting

### Common Issues

1. **Users can't access the platform**: Ensure they complete 2FA setup
2. **Message not appearing**: Check that `MFA_FORCE=true` is set correctly
3. **Translation missing**: Add translations to the appropriate locale files

### Disabling the Feature

To disable MFA forcing:

```bash
# Remove the environment variable or set it to false
MFA_FORCE=false
# or
unset MFA_FORCE
```

## Migration Guide

### For Existing Instances

1. **Backup**: Always backup your database before enabling this feature
2. **Communication**: Inform users about the new requirement
3. **Testing**: Test in a staging environment first
4. **Gradual Rollout**: Consider enabling for specific user groups first

### For New Instances

1. Set `MFA_FORCE=true` in your environment configuration
2. All new users will be required to set up 2FA during registration

## Related Features

- **Two-Factor Authentication**: The underlying 2FA system
- **Account Security**: General security features
- **User Management**: Admin tools for managing user accounts

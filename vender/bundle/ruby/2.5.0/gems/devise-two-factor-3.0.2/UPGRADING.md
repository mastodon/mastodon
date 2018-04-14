# Guide to upgrading from 2.x to 3.x

Pull request #76 allows for compatibility with `attr_encrypted` 3.0, which should be used due to a security vulnerability discovered in 2.0.

Pull request #73 allows for compatibility with `attr_encrypted` 2.0. This version changes many of the defaults which must be taken into account to avoid corrupted OTP secrets on your model.

Due to new security practices in `attr_encrypted` an encryption key with insufficient length will cause an error. If you run into this, you may set `insecure_mode: true` in the `attr_encrypted` options.

You should initially add compatibility by specifying the `attr_encrypted` attribute in your model (`User` for these examples) with the old default encryption algorithm before invoking `devise :two_factor_authenticatable`:
```ruby
class User < ActiveRecord::Base
  attr_encrypted :otp_secret,
    :key       => self.otp_secret_encryption_key,
    :mode      => :per_attribute_iv_and_salt,
    :algorithm => 'aes-256-cbc'

  devise :two_factor_authenticatable,
         :otp_secret_encryption_key => ENV['DEVISE_TWO_FACTOR_ENCRYPTION_KEY']
```

# Guide to upgrading from 1.x to 2.x

Pull request #43 added a new field to protect against "shoulder-surfing" attacks. If upgrading, you'll need to add the `:consumed_timestep` column to your `Users` model.

```ruby
class AddConsumedTimestepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :consumed_timestep, :integer
  end
end
```

All uses of the `valid_otp?` method should be switched to `validate_and_consume_otp!`

class CreateBlacklistedEmailDomains < ActiveRecord::Migration[5.1]
  def change
    create_table :blacklisted_email_domains do |t|
      t.string :domain, null: false

      t.timestamps
    end
  end
end

class CreateBlacklistedEmailDomains < ActiveRecord::Migration[5.1]
  def change
    create_table :blacklisted_email_domains do |t|
      t.string :domain, null: false
      t.string :note
 
      t.timestamps
    end
  end
end

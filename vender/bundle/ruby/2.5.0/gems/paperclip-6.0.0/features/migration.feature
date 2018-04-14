Feature: Migration

  Background:
    Given I generate a new rails application
    And I write to "app/models/user.rb" with:
      """
      class User < ActiveRecord::Base; end
      """

  Scenario: Vintage syntax
    When I write to "db/migrate/01_add_attachment_to_users.rb" with:
      """
      class AddAttachmentToUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.has_attached_file :avatar
          end
        end

        def self.down
          drop_attached_file :users, :avatar
        end
      end
      """
    And I run a migration
    Then I should have attachment columns for "avatar"

    When I rollback a migration
    Then I should not have attachment columns for "avatar"

  Scenario: New syntax with create_table
    When I write to "db/migrate/01_add_attachment_to_users.rb" with:
      """
      class AddAttachmentToUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.attachment :avatar
          end
        end
      end
      """
    And I run a migration
    Then I should have attachment columns for "avatar"

  Scenario: New syntax outside of create_table
    When I write to "db/migrate/01_create_users.rb" with:
      """
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :users
        end
      end
      """
    And I write to "db/migrate/02_add_attachment_to_users.rb" with:
      """
      class AddAttachmentToUsers < ActiveRecord::Migration
        def self.up
          add_attachment :users, :avatar
        end

        def self.down
          remove_attachment :users, :avatar
        end
      end
      """
    And I run a migration
    Then I should have attachment columns for "avatar"

    When I rollback a migration
    Then I should not have attachment columns for "avatar"

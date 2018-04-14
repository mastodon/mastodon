Feature: Rails integration

  Background:
    Given I generate a new rails application
    And I run a rails generator to generate a "User" scaffold with "name:string"
    And I run a paperclip generator to add a paperclip "attachment" to the "User" model
    And I run a migration
    And I update my new user view to include the file upload field
    And I update my user view to include the attachment
    And I allow the attachment to be submitted

  Scenario: Configure defaults for all attachments through Railtie
    Given I add this snippet to config/application.rb:
      """
      config.paperclip_defaults = {
        :url => "/paperclip/custom/:attachment/:style/:filename",
        :validate_media_type => false
      }
      """
    And I attach :attachment
    And I start the rails application
    When I go to the new user page
    And I fill in "Name" with "something"
    And I attach the file "spec/support/fixtures/animated.unknown" to "Attachment"
    And I press "Submit"
    Then I should see "Name: something"
    And I should see an image with a path of "/paperclip/custom/attachments/original/animated.unknown"
    And the file at "/paperclip/custom/attachments/original/animated.unknown" should be the same as "spec/support/fixtures/animated.unknown"

  Scenario: Add custom processors
    Given I add a "test" processor in "lib/paperclip"
    And I add a "cool" processor in "lib/paperclip_processors"
    And I attach :attachment with:
      """
      styles: { original: {} }, processors: [:test, :cool]
      """
    And I start the rails application
    When I go to the new user page
    And I fill in "Name" with "something"
    And I attach the file "spec/support/fixtures/5k.png" to "Attachment"
    And I press "Submit"
    Then I should see "Name: something"
    And I should see an image with a path of "/paperclip/custom/attachments/original/5k.png"

  Scenario: Filesystem integration test
    Given I attach :attachment with:
      """
        :url => "/system/:attachment/:style/:filename"
      """
    And I start the rails application
    When I go to the new user page
    And I fill in "Name" with "something"
    And I attach the file "spec/support/fixtures/5k.png" to "Attachment"
    And I press "Submit"
    Then I should see "Name: something"
    And I should see an image with a path of "/system/attachments/original/5k.png"
    And the file at "/system/attachments/original/5k.png" should be the same as "spec/support/fixtures/5k.png"

  Scenario: S3 Integration test
    Given I attach :attachment with:
      """
        :storage => :s3,
        :path => "/:attachment/:style/:filename",
        :s3_credentials => Rails.root.join("config/s3.yml"),
        :styles => { :square => "100x100#" }
      """
    And I write to "config/s3.yml" with:
      """
      bucket: paperclip
      access_key_id: access_key
      secret_access_key: secret_key
      s3_region: us-west-2
      """
    And I start the rails application
    When I go to the new user page
    And I fill in "Name" with "something"
    And I attach the file "spec/support/fixtures/5k.png" to "Attachment" on S3
    And I press "Submit"
    Then I should see "Name: something"
    And I should see an image with a path of "//s3.amazonaws.com/paperclip/attachments/original/5k.png"
    And the file at "//s3.amazonaws.com/paperclip/attachments/original/5k.png" should be uploaded to S3

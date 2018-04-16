Feature: Rake tasks

  Background:
    Given I generate a new rails application
    And I run a rails generator to generate a "User" scaffold with "name:string"
    And I run a paperclip generator to add a paperclip "attachment" to the "User" model
    And I run a migration
    And I attach :attachment with:
      """
        :path => ":rails_root/public/system/:attachment/:style/:filename"
      """

  Scenario: Paperclip refresh thumbnails task
    When I modify my attachment definition to:
      """
      has_attached_file :attachment, :path => ":rails_root/public/system/:attachment/:style/:filename",
                                     :styles => { :medium => "200x200#" }
      """
    And I upload the fixture "5k.png"
    Then the attachment "medium/5k.png" should have a dimension of 200x200
    When I modify my attachment definition to:
      """
      has_attached_file :attachment, :path => ":rails_root/public/system/:attachment/:style/:filename",
                                     :styles => { :medium => "100x100#" }
      """
    When I successfully run `bundle exec rake paperclip:refresh:thumbnails CLASS=User --trace`
    Then the attachment "original/5k.png" should exist
    And the attachment "medium/5k.png" should have a dimension of 100x100

  Scenario: Paperclip refresh metadata task
    When I upload the fixture "5k.png"
    And I swap the attachment "original/5k.png" with the fixture "12k.png"
    And I successfully run `bundle exec rake paperclip:refresh:metadata CLASS=User --trace`
    Then the attachment should have the same content type as the fixture "12k.png"
    And the attachment should have the same file size as the fixture "12k.png"

  Scenario: Paperclip refresh missing styles task
    When I upload the fixture "5k.png"
    Then the attachment file "original/5k.png" should exist
    And the attachment file "medium/5k.png" should not exist
    When I modify my attachment definition to:
      """
      has_attached_file :attachment, :path => ":rails_root/public/system/:attachment/:style/:filename",
                                     :styles => { :medium => "200x200#" }
      """
    When I successfully run `bundle exec rake paperclip:refresh:missing_styles --trace`
    Then the attachment file "original/5k.png" should exist
    And the attachment file "medium/5k.png" should exist

  Scenario: Paperclip clean task
    When I upload the fixture "5k.png"
    And I upload the fixture "12k.png"
    Then the attachment file "original/5k.png" should exist
    And the attachment file "original/12k.png" should exist
    When I modify my attachment definition to:
      """
      has_attached_file :attachment, :path => ":rails_root/public/system/:attachment/:style/:filename"
      validates_attachment_size :attachment, :less_than => 10.kilobytes
      """
    And I successfully run `bundle exec rake paperclip:clean CLASS=User --trace`
    Then the attachment file "original/5k.png" should exist
    But the attachment file "original/12k.png" should not exist

class ExampleMailer < ActionMailer::Base
  default from: "from@example.com"

  def test_message
    mail to: 'to@example.org', subject: 'Test Message'
  end
end

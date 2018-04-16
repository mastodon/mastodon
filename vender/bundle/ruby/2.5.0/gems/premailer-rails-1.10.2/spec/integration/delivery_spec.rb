require 'spec_helper'

describe 'ActionMailer::Base delivery' do
  it 'delivers email with inlined CSS' do
    WelcomeMailer.welcome_email("world").deliver_now

    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present
    body = mail.html_part.body.to_s
    expect(body).to be_present
    expect(body).to include(%{<p style="font-size: 12px;">Hello world</p>})
  end
end

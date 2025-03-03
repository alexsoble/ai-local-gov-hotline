require 'sinatra'
require 'twilio-ruby'

post '/hotline' do
  content_type 'text/xml'

  Twilio::TwiML::VoiceResponse.new do | response |
    response.say(message: "Hello World")
  end.to_s
end

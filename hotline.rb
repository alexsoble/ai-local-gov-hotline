require 'sinatra'
require 'twilio-ruby'

post '/hotline' do
  content_type 'text/xml'

  WELCOME_MESSAGE = 'Hello and welcome to the Water Department hotline.'

  Twilio::TwiML::VoiceResponse.new do | response |
    response.say(message: WELCOME_MESSAGE)
  end.to_s
end

require 'sinatra'
require 'dotenv/load'
require './claude_wrapper.rb'
require './twilio_wrapper.rb'

get '/' do 
  return 'Hello, world!'  
end

post '/hotline' do
  content_type 'text/xml'

  WELCOME_MESSAGE = 'Hello and welcome to the Water Department hotline. How may we assist you today?'

  TwilioWrapper.new.say_and_gather(
    message: WELCOME_MESSAGE,
    action: '/handle_speech'
  )
end

post '/handle_speech' do   
  response = ClaudeWrapper.new(params['SpeechResult']).claude_response

  TwilioWrapper.new.say_and_gather(
    message: response,
    action: '/handle_speech'
  )
end
require 'sinatra'
require 'dotenv/load'
require 'fileutils'
require './claude_wrapper.rb'
require './twilio_wrapper.rb'
require 'logger'

configure do
  set :logging, Logger::DEBUG
end

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
    call_sid = params['CallSid']
    status_file = "tmp/background/#{call_sid}.json"

    File.write(status_file, JSON.generate({
        status: "processing",
        timestamp: Time.now.to_i
    }))

    Thread.new do
        response = ClaudeWrapper.new(params['SpeechResult']).claude_response

        File.write(status_file, JSON.generate({
          status: "completed",
          timestamp: Time.now.to_i,
          response: response,
        }))
    end

    TwilioWrapper.new.say_and_redirect(
        message: 'One moment while I look up that information for you.',
        url: '/check-status-filesystem?call_sid=' + call_sid
    )
end

post '/check-status-filesystem' do
    call_sid = params['call_sid']
    status_file = "tmp/background/#{call_sid}.json"

    if File.exist?(status_file)
        data = JSON.parse(File.read(status_file))
        response = data['response']

        if data['status'] == 'completed'
            TwilioWrapper.new.say_and_gather(
                message: response,
                action: '/handle_speech'
            )
        else
            TwilioWrapper.new.pause_and_redirect(
                seconds: 2,
                url: '/check-status-filesystem?call_sid=' + call_sid
            )
        end
    else
        # Handle error case - status file missing
        TwilioWrapper.new.say_and_gather(
            message: "Sorry, we couldn't handle your query. Please try again.",
            action: '/handle_speech'
        )
    end
end

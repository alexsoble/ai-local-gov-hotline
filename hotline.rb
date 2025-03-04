require 'sinatra'
require 'fileutils'
require './apis/claude_wrapper.rb'
require './apis/twilio_wrapper.rb'
require 'logger'
require 'redis'

configure :development do
    # Load up local env from .env
    require 'dotenv/load'

    # Let's be verbose locally
    set :logging, Logger::DEBUG

    # Local redis
    $redis = Redis.new
end

configure :production do
    # Connect to Heroku Redis
    $redis = Redis.new(url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
end

WELCOME_MESSAGE = 'Hello and welcome to the Water Department hotline. You can ask me questions about anything: water service, billing, or sewer issues. How can I assist you today?'

post '/hotline' do
    TwilioWrapper.new.say_and_gather(
        message: WELCOME_MESSAGE,
        action: '/handle-speech'
    )
end

post '/handle-speech' do
    call_sid = params['CallSid']
    $redis.set("call:#{call_sid}:status", "processing")

    Thread.new do
        response = ClaudeWrapper.new(params['SpeechResult']).claude_response
        $redis.set("call:#{call_sid}:status", "completed")
        $redis.set("call:#{call_sid}:response", response)
    end

    TwilioWrapper.new.say_and_redirect(
        message: 'One moment please.',
        url: '/check-claude-response?call_sid=' + call_sid
    )
end

post '/check-claude-response' do
    call_sid = params['call_sid']
    status = $redis.get("call:#{call_sid}:status")
    response = $redis.get("call:#{call_sid}:response")

    if status == 'completed'
        TwilioWrapper.new.say_and_gather(
            message: response,
            action: '/handle-speech'
        )
    else
        TwilioWrapper.new.pause_and_redirect(
            seconds: 2,
            url: '/check-claude-response?call_sid=' + call_sid
        )
    end
end

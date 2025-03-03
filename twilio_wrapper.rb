require 'twilio-ruby'

class TwilioWrapper
	def say_and_gather(message: message, action: action)
	  Twilio::TwiML::VoiceResponse.new do |response|
	    response.say(message: message)

	    response.gather(
	      input: 'speech',
	      action: action,
	      method: 'POST'
	    )
	  end.to_s
	end

	def say(message: message)
	  Twilio::TwiML::VoiceResponse.new do |response|
	    response.say(message: message)
	  end.to_s
	end 
end
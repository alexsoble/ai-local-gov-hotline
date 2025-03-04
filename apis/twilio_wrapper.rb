require 'twilio-ruby'


# Twilio default is 5 seconds of user silence before timing out the "Gather"
# action, be slightly more generous than that.
SPEECH_TIMEOUT = 6

class TwilioWrapper
	def say_and_gather(message:, action:)
		Twilio::TwiML::VoiceResponse.new do |response|
	    	response.say(message: message)

	    	response.gather(
				input: 'speech',
				action: action,
				method: 'POST',
				action_on_empty_result: true,
				speech_timeout: SPEECH_TIMEOUT
	    	)
	  end.to_s
	end

	def say_and_redirect(message:, url:)
		Twilio::TwiML::VoiceResponse.new do |response|
		    response.say(message: message)
		    response.redirect(url)
		end.to_s
	end

	def say(message:)
		Twilio::TwiML::VoiceResponse.new do |response|
		    response.say(message: message)
		end.to_s
	end

	def pause_and_redirect(seconds:, url:)
		Twilio::TwiML::VoiceResponse.new do |response|
			response.pause(length: seconds)
			response.redirect(url)
		end.to_s
	end
end

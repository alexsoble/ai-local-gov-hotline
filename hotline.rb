require "sinatra"
require "twilio-ruby"

post "/hotline" do
  content_type "text/xml"

  WELCOME_MESSAGE = "Hello and welcome to the Water Department hotline. How may we assist you today?"

  Twilio::TwiML::VoiceResponse.new do | response |
    response.say(
      message: WELCOME_MESSAGE
    )

    response.gather(
      input: "speech",
      action: "https://guarded-atoll-40934-2505c0c0e70b.herokuapp.com/handle_speech",
      method: "POST"
    )
  end.to_s
end

post "/handle_speech" do   
  puts(params)
end
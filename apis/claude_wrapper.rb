require 'httparty'
require 'json'

class ClaudeWrapper
	attr_reader :claude_response  

	def initialize(speech_input)
		@speech_input = speech_input
		@prompt = build_prompt
		@claude_key = ENV['CLAUDE_KEY']
		@raw_claude_response = query_claude
		@claude_response = parse_claude_response
	end

	def build_prompt
		sewer_service_faq = File.read('./faq_data/sewer_service_faq.txt')
		water_service_faq = File.read('./faq_data/water_service_faq.txt')
		utility_billing_faq = File.read('./faq_data/utility_billing_faq.txt')

		return "You are an expert customer service agent for the City of Raleigh Water Department.

		Here are the key answers to commonly-asked questions about Raleigh water:
		#{sewer_service_faq}
		#{water_service_faq}
		#{utility_billing_faq}

		Here is the customer's question: '#{@speech_input}'

		What is your answer? Please respond in a short, conversational way as if you
		were an efficient, concise customer service agent."
	end

	def query_claude
		body = {
		    'model': 'claude-3-7-sonnet-20250219',
		    'max_tokens': 1024,
		    'messages': [
		        {'role': 'user', 'content': @prompt}
		    ]
		}.to_json

		headers = {
			'content-type:': 'application/json',
			'x-api-key': @claude_key,
			'anthropic-version': '2023-06-01',			
		}

		return HTTParty.post(
			'https://api.anthropic.com/v1/messages',
			body: body,
			headers: headers
		)
	end

	def parse_claude_response
		@raw_claude_response['content'][0]['text'].gsub('#', '') 
	end
end

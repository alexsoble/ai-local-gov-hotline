deploy:
	git push heroku main

local:
	bundle exec ruby ./hotline.rb
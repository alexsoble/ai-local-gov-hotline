install:
	bundle install

deploy:
	git push heroku main

serve:
	brew services start redis && bundle exec ruby ./hotline.rb

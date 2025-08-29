setup:
	bundle check || bundle install

lint:	setup
	bundle exec pod lib lint --allow-warnings --verbose

release: lint
	bundle exec pod trunk push

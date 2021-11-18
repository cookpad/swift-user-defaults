PODSPEC = swift-user-defaults.podspec

setup:
	bundle install

lint:	setup
	bundle exec pod lib lint --allow-warnings

release: lint
	bundle exec pod trunk push $(PODSPEC)

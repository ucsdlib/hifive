# Makefile for common High Five! development tasks

menu:
	@echo 'build: Run docker-compose build for the current ENV (development, production)'
	@echo 'clean: Run docker-compose down -v for the current ENV (development, production)'
	@echo 'console: Run rails console for debugging and local development'
	@echo 'ldap: Run rake task to populate the application with employee ldap data'
	@echo 'lint: Run rubocop to lint all files in the project'
	@echo 'seed: Run docker-compose up for the development environment'
	@echo 'test: Run full rspec test suite using RAILS_ENV=test'
	@echo 'up: Run docker-compose up for the current ENV (development, production)'

build:
	@echo 'Building docker-compose environment'
	@docker-compose build

clean:
	@echo 'Cleaning out docker-compose environment'
	@docker-compose down -v

console:
	@echo 'Running rails console'
	@docker-compose exec web bundle exec rails console

lint:
	@echo 'Running Rubocop'
	@docker-compose exec web bundle exec rubocop

ldap:
	@echo 'Populating employee LDAP data'
	@docker-compose exec web bundle exec rake nightly:employees

seed:
	@echo 'Seeding database with sample data'
	@docker-compose exec web bundle exec rake db:seed

test:
	@echo 'Running full test suite'
	@docker-compose exec -e RAILS_ENV=test web bundle exec rake db:create db:schema:load
	@docker-compose exec -e RAILS_ENV=test web bundle exec rake spec

up:
	@echo 'Bringing up docker-compose environment'
	@docker-compose up

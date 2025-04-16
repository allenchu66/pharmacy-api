setup:
	DB_HOST=db docker-compose run -e RAILS_ENV=development web bundle exec rake db:create db:migrate db:seed

start:
	docker-compose up -d

stop:
	docker-compose down

console:
	docker-compose exec web rails console

bash:
	docker-compose exec web bash

psql:
	docker-compose exec db psql -U $$DB_USERNAME -d phantom_mask_development

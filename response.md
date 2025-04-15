## A. Required Information
### A.1. Requirement Completion Rate
- [x] List all pharmacies open at a specific time and on a day of the week if requested.
  - Implemented at `/api/pharmacies?day_of_week={0-6}&time=HH:mm`
  - Test : [http://35.229.247.36:3000/api/pharmacies?day_of_week=1&time=14:00](http://35.229.247.36:3000/api/pharmacies?day_of_week=1&time=14:00)
- [x] List all masks sold by a given pharmacy, sorted by mask name or price.
  - Implemented at `/api/pharmacies/:pharmacy_id/masks?sort=price_asc`
  - Test : [http://35.229.247.36:3000/api/pharmacies/1/masks?sort=price_asc](http://35.229.247.36:3000/api/pharmacies/1/masks?sort=price_asc)
  - Implemented at `/api/pharmacies/:pharmacy_id/masks?sort=price_desc`  
  - Test : [http://35.229.247.36:3000/api/pharmacies/1/masks?sort=price_desc](http://35.229.247.36:3000/api/pharmacies/1/masks?sort=price_desc)
  - Implemented at `/api/pharmacies/:pharmacy_id/masks?sort=name_asc`  
  - Test : [http://35.229.247.36:3000/api/pharmacies/1/masks?sort=name_asc](http://35.229.247.36:3000/api/pharmacies/1/masks?sort=name_asc)
  - Implemented at `/api/pharmacies/:pharmacy_id/masks?sort=name_desc`  
  - Test : [http://35.229.247.36:3000/api/pharmacies/1/masks?sort=name_desc](http://35.229.247.36:3000/api/pharmacies/1/masks?sort=name_desc)
- [x] List all pharmacies with more or less than x mask products within a price range.
  - Implemented at `/api/pharmacies/filter_by_mask_conditions?mask_price_min=5&mask_price_max=20&stock_gt=2&stock_lt=6`
  - Test : [http://35.229.247.36:3000/api/pharmacies/filter_by_mask_conditions?mask_price_min=5&mask_price_max=20&stock_gt=2&stock_lt=6](http://35.229.247.36:3000/api/pharmacies/filter_by_mask_conditions?mask_price_min=5&mask_price_max=20&stock_gt=2&stock_lt=6)
- [x] The top x users by total transaction amount of masks within a date range.
  - Implemented at `/api/orders/analytics/top_users?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD&limit=x
  - Test : [http://35.229.247.36:3000/api/orders/analytics/top_users?start_date=2021-01-01&end_date=2021-01-31&limit=3](http://35.229.247.36:3000/api/orders/analytics/top_users?start_date=2021-01-01&end_date=2021-01-31&limit=3)
- [x] The total number of masks and dollar value of transactions within a date range.
  - Implemented at `/api/orders/analytics/statistics?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD`
  - Test : [http://35.229.247.36:3000/api/orders/analytics/statistics?start_date=2021-01-01&end_date=2021-01-31](http://35.229.247.36:3000/api/orders/analytics/statistics?start_date=2021-01-01&end_date=2021-01-31)
- [x] Search for pharmacies or masks by name, ranked by relevance to the search term.
  - Implemented at `/api/search?keyword=xxx`
  - Test : []()
- [x] Process a user purchases a mask from a pharmacy, and handle all relevant data changes in an atomic transaction.
  - Implemented at `/api/orders`
  - Test : []()
### A.2. API Document
> Please describe how to use the API in the API documentation. You can edit by any format (e.g., Markdown or OpenAPI) or free tools (e.g., [hackMD](https://hackmd.io/), [postman](https://www.postman.com/), [google docs](https://docs.google.com/document/u/0/), or  [swagger](https://swagger.io/specification/)).

Import [this](#api-document) json file to Postman.

### A.3. Import Data Commands
Please run these two script commands to migrate the data into the database.

```bash
$ rake import_data:pharmacies[PATH_TO_FILE]
$ rake import_data:users[PATH_TO_FILE]
```
## B. Bonus Information

>  If you completed the bonus requirements, please fill in your task below.
### B.1. Test Coverage Report

I wrote down the 20 unit tests for the APIs I built. Please check the test coverage report at [here](#test-coverage-report).

You can run the test script by using the command below:

```bash
bundle exec rspec spec
```

### B.2. Dockerized
Please check my Dockerfile / docker-compose.yml at [here](#dockerized).

On the local machine, please follow the commands below to build it.

```bash
$ docker build --build-arg ENV=development -p 80:3000 -t my-project:1.0.0 .  
$ docker-compose up -d

# go inside the container, run the migrate data command.
$ docker exec -it my-project bash
$ rake import_data:pharmacies[PATH_TO_FILE] 
$ rake import_data:user[PATH_TO_FILE]
```

### B.3. Demo Site Url

The demo site is ready on [my AWS demo site](#demo-site-url); you can try any APIs on this demo site.

## C. Other Information

### C.1. ERD

My ERD [erd-link](#erd-link).

### C.2. Technical Document

For frontend programmer reading, please check this [technical document](technical-document) to know how to operate those APIs.

- --

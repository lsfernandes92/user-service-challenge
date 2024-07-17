# Final clarifications

The purpose of this document is to:

- Clarify some details I left open due to the deadline.
- Share my thoughts and experiences while developing the take-home project.
- Provide any other relevant information.

Feel free to poke around the code and see how I've structured it by yourself. Although, for the sake of saving time, here are my main classes in the system:

- User model, found in `app/models/user.rb`. This model is responsible for encapsulate user data and serialization logic.
- User controller, found in `app/controller/api/users_controller.rb`. This controller handles user interactions through the API. It responds to `GET` and `POST` requests related to users.
- Gather account key job, found in `app/jobs/gather_account_key_job.rb`. This background job retrieves the account key from the **Account Key Service**.
- Gather account key service, found in `app/services/gather_account_key_service.rb`. This service is called by the **Gather Account Key Job** to retrieve the account key from the **Account Key Service**. It contains the logic for obtaining the account key and updating the User model.
- Account key service, found in `lib/api/external_services/account_key_service.rb`. This service provides a well-defined interface for securely exchanging information (gathering the account key) with the external **Account Key Service**.
- Request, found in `lib/api/request.rb`. This class acts as an abstraction for handling `POST` requests the system needs to make to communicate with the **Account Key Service**.
- Dev task, found in `lib/tasks/dev.rake`. I created this task to simplify the initial development process. Running this task seeds your development database with some sample users. This allows you to test the `GET /api/users` request with pre-populated data

## MVP

I've reviewed the TODOs, and you can see what's been completed by checking the. [README.md](./README.md)

## How to run the test suite

Follow the instructions on how to getting started in the [README.md](./README.md) file to set up your development environment. Once you've completed the setup steps, open your terminal and run the following command:

`$ docker compose run web rspec`

The command you just ran will execute the entire test suite. However, if you prefer to run specific tests individually, you can use the following syntax:

`$ docker compose run web rspec <PATH_TO_THE_SPEC_FILE>`

Like, for example:

`$ docker compose run web rspec spec/requests/users_spec.rb`

And here is an output example:

```shell
Api::ExternalServices::AccountKeyService
  #gather_account_key
    when correct data provided
      returns account_key as string
      returns json object with error
    when email is blank
      returns 422 Unprocessable Entity
      logs error message
    when key is blank
      returns 422 Unprocessable Entity
      logs error message
  #request_succeed?
    returns true when account key service succeed
    returns false when account key service fails

Api::Request
  #post
    with the correct data provide
      returns json object with email and account_key
    with the wrong data provided
      when the URL is wrong
        returns a json error object
        logs error message
      when the payload is wrong
        returns a json error object
        logs error message
      when the header is wrong
        returns a json error object
        logs error message

Api::UsersController
  when routing to
    GET /api/users
      routes to the api/users#index
    POST /api/users
      routes to the api/users#create

GatherAccountKeyJob
  #perform
2024-07-17T13:36:10.102Z pid=1 tid=3kd INFO: Sidekiq 7.2.4 connecting to Redis with options {:size=>10, :pool_name=>"internal", :url=>"redis://redis:6379/1"}
    queues the job
    queues in the default queue
    calls GatherAccountKeyService (PENDING: Temporarily skipped with xit)
    retries on error and succeeds on retry (PENDING: Temporarily skipped with xit)
    with failing GatherAccountKeyService
      raises an error (PENDING: Temporarily skipped with xit)

User
  when is being created
    succeds with valid attributes
    generates the key automagically
    sets account_key to nil
    generates a salt password automagically
    queues job to gather account key
  with validations
    on email attribute
      validates presence
      validates maximum length
      validates uniqueness
      validates format
    on phone_number attribute
      validates presence
      validates maximum length
      validates uniqueness
    on full_name attribute
      validates maximum length
    on password attribute
      validates presence
      validates maximum length
    on key attribute
      when a user is being reassign
        validates presence
        validates maximum length
        validates uniqueness
    on account_key attribute
      when a user is being reassign
        validates maximum length
        validates uniqueness
        does not validate uniqueness on nil
  when using scope
    .most_recently
      returns users sorted by creation date (most recent first)
      return nil when no id passed
    .by_email
      returns users by a given email
      returns nil with invalid email
    .by_full_name
      returns users by a given full_name
      returns users with the same full_name
      returns nil with invalid full_name
    .by_metadata
      returns users by a given full_name
      return nil with invalid metadata
  #as_json
    returns only the desirable atributes for the user
  .generate_random_sanitized_metadata
    returns random sanitized metadata

Users
  GET /api/users
    returns status code 200
    responds with users
    responds with users sorted by creation date (most recent first)
    request with query params
      passing the email
        returns user with a given email
        returns nil with non existed email
      passing the full_name
        returns user with a given full_name
        returns nil with non existed full_name
        returns users with the same full_name sorted by creation date (most recent first)
      passing the metadata
        returns user with a given metadata
        returns nil with non existed full_name
      passing multiple query params
        returns user with granular search
      passing unpermitted query params
        responds with an 'errors' object
        responds with an error message
  POST /api/users
    with valid params
      returns status code 201
      responds with a single user object
      queues job to gather account key
    with invalid params
      returns status code 422
      responds with an array of errors
      passing non-unique params
        returns status code 422
        responds with an array of errors
      passing unpermitted params
        returns status code 422
        responds with an array of errors

GatherAccountKeyService
  #perform
    when the user exists
      finds the user by email
      sets the user account_key and saves the user
    with user not found
      raises an error

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) GatherAccountKeyJob#perform calls GatherAccountKeyService
     # Temporarily skipped with xit
     # ./spec/jobs/gather_account_key_job_spec.rb:22

  2) GatherAccountKeyJob#perform retries on error and succeeds on retry
     # Temporarily skipped with xit
     # ./spec/jobs/gather_account_key_job_spec.rb:35

  3) GatherAccountKeyJob#perform with failing GatherAccountKeyService raises an error
     # Temporarily skipped with xit
     # ./spec/jobs/gather_account_key_job_spec.rb:29


Finished in 7.2 seconds (files took 1.69 seconds to load)
79 examples, 0 failures, 3 pending
```

## Observations

### Seed the databse
As mentioned earlier, to simplify the initial setup, you can populate your development database with some sample users. This will give you data to view when you make a `GET /api/users` request.

Here's how to seed the database if your container is up and running:

`$ docker compose run web rails dev:setup`

### Challenge with account key retrieval

While implementing the background job feature to retrieve account keys externally, I encountered a challenge.  I couldn't find a way to immediately return the `account_key` field populated in the response when a user creates a new user via `POST /api/users`.

To address this, I decided to allow the `account_key` field to initially return `nil` in the response. And then right before the user receives the response, a background job is triggered. This job calls the `AccountKeyService` to retrieve the account key and update the user record. The entire process typically takes only a few seconds.

While the initial `POST /api/users` request won't include the `account_key` due to the background processing, you can subsequently retrieve it using a `GET /api/users?email=<DESIRABLE_EMAIL>` request. This will return the user information, including the generated `account_key`.

I discovered this behavior the day before returning the project. Given the tight deadline, I decided to document the current behavior for your review, rather than send a last-minute question.

## Future improvements

1. Sidekiq in Tests: During testing, Sidekiq logs can clutter the console output. I'd like to explore ways to identify which tests require Sidekiq to run the background job to see if I can skip some of this log outputs for the test environment.
2. While the requirement specifies "5xx for server errors," I may not have covered this aspect extensively in the tests.
3. I didn't get enough time to polish my tests on `spec/services/gather_account_key_service_spec.rb` and `spec/jobs/gather_account_key_job_spec.rb`.
4. The current validation approach for the `User` model requires a significant amount of code. Implementing a dedicated validator class could improve code organization.
5. `app/controllers/api/users_controller.rb` could be enhanced by utilizing a separate error object/serializer for better structure and clarity.

## Possible toubleshootings

### When Sidekiq configurations not being applied

If you notice that some Sidekiq configurations are not being applied, you can rebuild your container to ensure the changes take effect. Use the following command for that:

`$ docker compose up -d --build`

## References

- [What is a Salt password](https://crypto.stackexchange.com/questions/1776/what-is-a-cryptographic-salt)
- [Config raise error on unpermitted parameters](https://guides.rubyonrails.org/configuring.html#config-action-controller-action-on-unpermitted-parameters)
- [Sidekiq getting started](https://github.com/sidekiq/sidekiq/wiki/Getting-Started)
- [Sidekiq playlist on Youtube](https://www.youtube.com/watch?v=GBEDvF1_8B8&list=PL96HNs9nVaawSvxBnNRhJk-euEkpRfCDg&index=2)
- [Active job](https://github.com/sidekiq/sidekiq/wiki/Active+Job)
- [I considered storing the metadata like this, but ultimately decided against it](https://www.chrisblunt.com/rails-3-storing-model-metadata-attributes-with-activerecordstore/)
- [Factory bot trait to skip callback](https://gist.github.com/jaydorsey/600cee4090ba9994617320b93d63db4b)
- [Guide to caching ActiveRecord SQL queries in Rails](https://pawelurbanek.com/rails-active-record-caching?utm_source=pocket_saves)
- [HTTP Status Codes](https://httpstatuses.io/)
- [Factory bot gem getting started](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md)
- [Ruby-argon2 gem](https://github.com/technion/ruby-argon2)
- [Faker gem](https://github.com/faker-ruby/faker)

## Challenge

See [README.md](./README.md)
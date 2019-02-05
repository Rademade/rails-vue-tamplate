# Rails Vue template

# Current Stack:
- Ruby 2.4.5
- Rails 5.2.1
- Postgres
- Puma
- Sidekiq + Sidekiq-Scheduler

# What is included:

- Rspec as Default testing framework
- Rubocop with custom configuration
- Eslint with vue/recommended and airbnb-base rules
- Procfile for Heroku Deployment
- Webpacker version 3 basic config + enabled PostCss Loader
- Docker-compose setup for local development
- Basic Vue project structure with Vuex, Vue-Router and basic services (Api and Authentification with JWT)
- Overcommit commit to run rubocop and eslint on every commit
```
gem install overcommit
overcommit --install
```

# Installation
Set your application name in `.env` file.

# TODO:
- [ ] Implement JWT Authentification on the backend (preferably 'sorcery' gem)
- [ ] Circle CI integration
- [ ] Docker configuration for Rademade Docker Swarm env
- [ ] Performance, Security auto checking tools (bullet, etc...)
- [ ] Add test coverage tools (SimpleCov)
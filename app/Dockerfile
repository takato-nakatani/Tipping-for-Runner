FROM ruby:2.5.3

RUN mkdir /app

RUN apt-get update && apt-get install -y libpq-dev postgresql-client
WORKDIR /app
COPY . .
RUN gem install bundler && bundle install 

EXPOSE 80
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "80"]
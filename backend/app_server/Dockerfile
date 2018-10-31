FROM ruby:2.5.3-alpine

RUN mkdir /app

RUN apk update && apk upgrade
WORKDIR /app
COPY Gemfile .
RUN bundle install && bundle clean
COPY . /app
EXPOSE 80
CMD ["ruby", "app.rb", "-o", "0.0.0.0", "-p", "80"]
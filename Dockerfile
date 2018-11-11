FROM ruby:2.5.3

RUN mkdir /app

# RUN apk update && apk upgrade
RUN apt-get update
RUN gem install bundler
RUN apt-get install -y sqlite3 libsqlite3-dev
WORKDIR /app
# COPY Gemfile .
COPY . .
RUN bundle install 
EXPOSE 80
# CMD ["ruby", "app.rb", "-o", "0.0.0.0", "-p", "80"]
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "80"]
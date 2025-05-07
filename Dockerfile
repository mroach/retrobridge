FROM ruby:3.4

WORKDIR /opt/app

COPY Gemfile Gemfile.lock ./

ENV BUNDLE_DEPLOYMENT=true \
    RACK_ENV=production

RUN bundle config set deployment true \
    && bundle config set without "test development" \
    && bundle install

COPY . .

CMD ["bin/serve"]

FROM ruby:3.2.2
RUN mkdir /app
WORKDIR /app
ARG _ARM_ARCH="arm-unknown-linux-gnu"

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["sh", "docker-entrypoint.sh"]
EXPOSE 80

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "80"]

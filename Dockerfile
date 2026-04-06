FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
  build-essential \
  default-mysql-client \
  default-libmysqlclient-dev \
  git \
  curl \
  pkg-config \
  libyaml-dev \
  libvips \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint 2>/dev/null || true
RUN chmod +x entrypoint.sh 2>/dev/null || true

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

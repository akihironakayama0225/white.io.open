FROM ruby:2.6

RUN apt update -y && apt install -y build-essential \
    && apt install -y redis-server \
    && rm -rf /var/lib/apt/lists/*

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

# Install yarn
# https://classic.yarnpkg.com/en/docs/install#debian-stable
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install yarn

# Create directory and copy files
ENV HOME="/app"
WORKDIR $HOME
ADD ./rails_app/Gemfile      $HOME/Gemfile
ADD ./rails_app/Gemfile.lock $HOME/Gemfile.lock

RUN bundle install
ADD ./rails_app $HOME

CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]
#CMD ["rails", "server", "-b", "0.0.0.0"]
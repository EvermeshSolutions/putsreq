FROM ruby:2.5.5

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -qq -y build-essential nodejs yarn \
    libpq-dev \
    --no-install-recommends

WORKDIR /app

## help docker cache bundle
ADD Gemfile                      /app/
ADD Gemfile.lock                 /app/
RUN bundle install

## Add & compile Webpack code in order from least likely to most likely to change to improve layer caching.
ADD .babelrc                            /app/.babelrc
ADD .postcssrc.yml                      /app/.postcssrc.yml
ADD bin/webpack                         /app/bin/webpack
ADD vendor                              /app/vendor
ADD public                              /app/public
ADD config/webpacker.yml                /app/config/webpacker.yml
ADD config/webpack                      /app/config/webpack
ADD config/locales                      /app/config/locales
ADD app/assets                          /app/app/assets
ADD app/javascript                      /app/app/javascript

## Add APP code in order from least likely to most likely to change to improve layer caching.
ADD config.ru                           /app/config.ru
ADD Rakefile                            /app/Rakefile
ADD config                              /app/config
ADD lib                                 /app/lib
ADD bin                                 /app/bin
ADD app                                 /app/app

EXPOSE 3000

CMD ["bash"]

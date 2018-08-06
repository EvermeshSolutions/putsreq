FROM ruby:2.5.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs --no-install-recommends

WORKDIR /app

## help docker cache bundle
ADD Gemfile                      /app/
ADD Gemfile.lock                 /app/
RUN bundle install

## install node modules
ADD package.json         /app/
ADD package-lock.json    /app/
# RUN npm install

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
# RUN npm run build

## Add APP code in order from least likely to most likely to change to improve layer caching.
ADD config.ru                           /app/config.ru
ADD Rakefile                            /app/Rakefile
ADD config                              /app/config
ADD lib                                 /app/lib
ADD bin                                 /app/bin
ADD app                                 /app/app

EXPOSE 3000

CMD ["bash"]

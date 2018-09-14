FROM ruby:2.4.4

LABEL maintainer "peace_data <peace_data@cocaine.ninja>" \
      description "Ruby on Rails project - SAP, RybyCon LLC"

RUN bundle config --global frozen 1

# Add Yarn
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg
RUN echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

RUN true \
    && apt-get update -qq \
    && apt-get install -y build-essential \
    libpq-dev \
    nodejs npm \
    git ghostscript \
    imagemagick libc6 libffi6 libgcc1 libgmp-dev default-libmysqlclient-dev \
    libncurses5 libpq5 libreadline-dev libssl1.0-dev libstdc++6 libtinfo5 \
    libxml2-dev libxslt1-dev zlib1g zlib1g-dev netcat-traditional gnupg curl openssl yarn mariadb-client \
    && apt-get clean \
    && true

# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT /var/www/sap
RUN mkdir -p $RAILS_ROOT

# Set working directory
WORKDIR $RAILS_ROOT

# Setting env up
ENV RAILS_ENV production
ENV RAKE_ENV production

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install \
    && npm install -g npm \
    && npm install \
    && npm install jquery

# Adding project files
COPY . .

EXPOSE 3000

RUN ["chmod", "+x", "/var/www/sap/entrypoint.sh"]

ENTRYPOINT ["/var/www/sap/entrypoint.sh"]
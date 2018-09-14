FROM ruby:2.4.4

LABEL maintainer "peace_data <peace_data@cocaine.ninja>" \
      description "Ruby on Rails project - SAP, RybyCon LLC"

RUN bundle config --global frozen 1

# Add Yarn
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg
RUN echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - 
#    && apt-get install -y nodejs

RUN true \
    && apt-get update \
    && apt-get install -y --no-install-recommends build-essential software-properties-common \
    libpq-dev gcc g++ make \
    nodejs \
    git ghostscript \
    imagemagick libc6 libffi6 libgcc1 libgmp-dev default-libmysqlclient-dev \
    libncurses5 libpq5 libreadline-dev libssl1.0-dev libstdc++6 libtinfo5 \
    libxml2-dev libxslt1-dev zlib1g zlib1g-dev netcat-traditional gnupg curl openssl yarn mariadb-client \
    && apt-get clean \
    && true

ADD https://www.npmjs.com/install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh \
    && ./tmp/install.sh

# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT /var/www/sap
RUN mkdir -p $RAILS_ROOT

# Set working directory
WORKDIR $RAILS_ROOT

RUN yarn add npm:latest

# Setting env up
ENV RAILS_ENV production
ENV RAKE_ENV production

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
RUN npm install -g npm
RUN npm install jquery

# Adding project files
COPY . .

EXPOSE 3000

RUN ["chmod", "+x", "/var/www/sap/entrypoint.sh"]

ENTRYPOINT ["/var/www/sap/entrypoint.sh"]

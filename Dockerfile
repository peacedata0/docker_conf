FROM ruby:2.4.4-stretch

LABEL maintainer "peace_data <peace_data@cocaine.ninja>" \
      description "Project - SAP, Ruby on Rails, RybyCon LLC"

USER root

# Install bash
RUN true \
    && apt-get update \
    && apt-get install -y --no-install-recommends bash=4.4-5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && true

# Use bash as the default shell
SHELL ["/bin/bash", "-c"]

RUN bundle config --global frozen 1

# Add Yarn
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg
RUN echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - 

RUN true \
    && apt-get update \
    && apt-get install -y --no-install-recommends build-essential software-properties-common \
    libpq-dev gcc g++ make \
    nodejs sudo ca-certificates \
    git ghostscript \
    imagemagick libc6 libffi6 libgcc1 libgmp-dev default-libmysqlclient-dev \
    libncurses5 libpq5 libreadline-dev libssl1.0-dev libstdc++6 libtinfo5 \
    libxml2-dev libxslt1-dev zlib1g zlib1g-dev netcat-traditional gnupg curl openssl yarn mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && true

ADD https://www.npmjs.com/install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh \
    && ./tmp/install.sh

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }').asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Remove unneeded apt cache
RUN rm -rf /var/cache/apt/* /tmp/*

# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT /var/www/sap

# Force sudoers to not being asked the password
RUN echo "%sudo        ALL=NOPASSWD: ALL" >> /etc/sudoers

# Add require user and add him to sudoers group
RUN useradd -U -m --shell /bin/bash --no-log-init peace_data \
    && usermod -aG sudo peace_data

# Set working directory
RUN gosu root mkdir -p $RAILS_ROOT
WORKDIR /var/www/sap

# Setting env up
ENV RAILS_ENV production
ENV RAKE_ENV production
ENV RAILS_SERVE_STATIC_FILES true

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

# Adding project files
COPY . .

# Change default owner & fix permissions
RUN gosu root chown -R peace_data /var/www/sap/ \
    && chmod -R 755 /var/www/sap/ \
    && gosu root chown -R peace_data /usr/local/bundle/config \
    && chmod -R 755 /usr/local/bundle/config

# Set project user
USER peace_data

EXPOSE 3000

RUN chmod +x /var/www/sap/entrypoint.sh \
    && chmod +x /var/www/sap/post_install

ENTRYPOINT [ "/var/www/sap/entrypoint.sh" ]
#!/bin/bash

sleep 20

cd /var/www/sap/


bundle install

export RAILS_ENV=production
export RAKE_ENV=production
export SECRET_KEY_BASE='411de7d5d917b719f1d73a94c1e76dd62c3ffd1a9ff8d8201d84d1478d9efe2ae005bb4d2a6f2fa2b45fe219f71dafb50062a5aae14afcd4b2429782757f7732'
export SAP_SECRET_KEY='16564d3225f524551849b29e7705c8397c094575d6c6e32ad31bec6f878c1dfec7d684a56fa1942003ef4e4efedb3bbae296246c3ffd285aba427bbf7a920586'
export SAP_DATABASE_HOST='mariadb'
export SAP_DATABASE_NAME='sap_production'
export SAP_DATABASE_USER='sap_user'
export SAP_DATABASE_PASSWORD='VVh0@mi?'
export RAILS_SERVE_STATIC_FILES='true'
export WEB_CONCURRENCY=4

rake assets:clean
rake assets:precompile
rake db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1
rake db:create
rake db:migrate
rake key_codes_definitions:parse:xml_codes
rake partners:import
rake product_code:import
bundle exec puma -C config/puma.rb

/bin/bash $PWD/post_install
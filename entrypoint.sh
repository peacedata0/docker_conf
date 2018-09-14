#!/bin/bash

bundle install
npm install -g npm
npm install
npm install jquery

export RAILS_ENV=production

rake assets:clean
rake assets:precompile
rake db:drop
rake db:create
rake db:migrate
rake key_codes_definitions:parse:xml_codes
rake partners:import
rake product_code:import
puma -C config/puma.rb
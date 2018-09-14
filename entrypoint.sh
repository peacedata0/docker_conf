#!/bin/bash

set -e
run_cmd="bundle exec rake assets:clean \
    && bundle exec rake assets:precompile \
    && bundle exec rake db:drop \
    && bundle exec rake db:create \
    && bundle exec rake db:migrate \
    && bundle exec rake key_codes_definitions:parse:xml_codes \
    && bundle exec rake partners:import \
    && bundle exec rake product_code:import \
    && bundle exec puma -C config/puma.rb"

until dotnet ef database update; do
>&2 echo "MariaDB Server is starting up"
sleep 1
done

>&2 echo "MariaDB Server is up - executing command"
exec $run_cmd

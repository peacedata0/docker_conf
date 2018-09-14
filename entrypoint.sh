#!/bin/bash

set -e
run_cmd="dotnet run Schedule.IntIta --server.urls http://*:44311"

until dotnet ef database update; do
>&2 echo "MySQL Server is starting up"
sleep 1
done

>&2 echo "MySQL Server is up - executing command"
exec $run_cmd

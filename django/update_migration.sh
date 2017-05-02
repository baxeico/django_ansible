#!/bin/bash

if [ -z $1 ]; then
    echo "Usage:  $0  app_label"
    exit 1
fi

app=$1 # this is the name of the app where we want to update the last migration

# get the list of known migrations for the app
migrations=(`./manage.py showmigrations $app | awk '{print $2}' | tail -2`)

if [ ${#migrations[@]} == 1 ]; then
    # there is just one migration in the list
    # here we are updating the initial migration
    previous_migration=zero
    current_migration=${migrations[0]} # should be 0001_initial
else
    # there is more than one migration in the list
    # get the previous one to go back to
    # and the current one to update
    previous_migration=${migrations[0]}
    current_migration=${migrations[1]}
fi

# go back to the previous migration
./manage.py migrate $app $previous_migration
# remove the current, outdated migration
rm $app/migrations/${current_migration}.*
# create a new migration
./manage.py makemigrations $app
# migrate the DB to the new migration
./manage.py migrate $app

#!/bin/bash
bin="/app/bin/anoma"

# Setup the database.
$bin eval "Anoma.Release.migrate"

# start the elixir application
exec "$bin" "start"
#!/bin/bash

echo "*** RESTORING DATABASE ***"
psql -U $POSTGRES_USER -d kumademo -f /tmp/psql_data/database.sql
echo "*** RESTORED KUMA DEMO DATABASE! ***"
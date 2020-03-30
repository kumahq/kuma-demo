#!/bin/bash

echo "*** RESTORING DATABASE ***"
echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf
psql -U $POSTGRES_USER -d kumademo -f /tmp/psql_data/database.sql
echo "*** RESTORED KUMA DEMO DATABASE! ***"
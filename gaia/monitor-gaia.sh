#/bin/bash

nc -z localhost 46656
P46656=$?
nc -z localhost 46657
P46657=$?

if [ $P46656 -ne 0 ] || [ $P46657 -ne 0 ];
then
  systemctl restart gaia.service
fi

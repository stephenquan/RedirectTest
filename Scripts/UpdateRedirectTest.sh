#!/bin/bash -xe


cd ..

Scripts/UpdatePortalItem.sh RedirectTest.qml RedirectTest
touch /tmp/timestamp.txt

while [ 1 == 1 ];
do
  c=$(find . -name RedirectTest.qml -newer /tmp/timestamp.txt | wc -l)
  echo $c
  if (( c == 1 )); then
    Scripts/UpdatePortalItem.sh RedirectTest.qml RedirectTest
    touch /tmp/timestamp.txt
  fi
  sleep 5
done



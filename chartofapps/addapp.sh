#!/bin/bash

# Check if a file name was provided as an argument
if [ $# -eq 0 ]; then
  echo "Usage: $0 filename"
  exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "File not found!"
  exit 1
fi

touch badapps.txt
# Read each line of the file and create an app yaml file from it
while IFS= read -r app
do
  echo "working on $app"
 kubectl -n argocd get app $app >/dev/null
if [ $? -eq 0 ]; then
 echo creating app yaml file
 kubectl -n argocd get app $app -o yaml > "$app"-raw.yaml
 cat "$app"-raw.yaml \
| yq  eval 'del(.status)' \
| yq  eval 'del(.metadata.annotations."kubectl.kubernetes.io/last-applied-configuration")' \
| yq  eval 'del(.metadata.creationTimestamp)' \
| yq  eval 'del(.metadata.generation)' \
| yq  eval 'del(.metadata.resourceVersion)' \
| yq  eval 'del(.metadata.labels."app.kubernetes.io/instance")' \
| yq  eval 'del(.metadata.uid)' > testtemplates/"$app".yaml

 rm -f "$app"-raw.yaml
 echo done creating "$app".yaml
 echo ---------------------------------------------------------------------
 else
   echo $app >> badapps.txt
   echo " skipping this app $app as it is not found in argocd namespace"
   echo ---------------------------------------------------------------------
   continue
fi
done < "$1"
echo
echo
echo
echo please take a look at these apps and run addapps.sh badapps.txt
cat badapps.txt

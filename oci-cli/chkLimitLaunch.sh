#!/bin/bash

usage="\n$(basename "$0") [-h] [-s SHAPE] [-c COMPARTMENT] [-a AD] -- launch new compute instance
\n
\nwhere:
\n -h show this help text
\n -s define instance shape
\n -c set compartment OCID
\n -a choose AD (default is AD-1)
\n"

while getopts 'hs:c:a:' option; do
  case "${option}" in
    h) echo -e $usage
        exit
        ;;
    s) SHAPE=${OPTARG};;
    c) CID=${OPTARG};;
    a) AD=${OPTARG};;
  esac
done

if [ -z "$AD" ]
then
  adName=$(oci iam availability-domain list --query 'data[*]|[0].name' --raw-output)
else
  adNum="$(($AD - 1))"
  adName=$(oci iam availability-domain list --query "data[*]|[${adNum}].name" --raw-output)
fi

if [ -z "$CID" ]
then
  echo "You did not enter a compartment OCID, grabbing the first one that we find"
  CID=$(oci iam compartment list --query 'data[*]|[0]."compartment-id"' --raw-output)
  echo "Using compartment OCID: $CID"
  echo ""
fi

if [ -z "$SHAPE" ]
then
  echo "You must specify a shape"
  exit
else
  
  getShape=$(echo "${SHAPE,,}")

  if [[ $getShape == *"denseio2"* ]]; then setShape=$(echo $getShape | sed -e 's/denseio2/dense.io2/g')
    else setShape=$getShape
  fi

useShape=$(echo "${setShape}" | sed -e 's/\./-/g')-count

fi

echo "oci limits resource-availability get --service-name compute -c $CID --limit-name $useShape --availability-domain $adName --query 'data.available' --raw-output"

shapeUsage=$(oci limits resource-availability get --service-name compute -c $CID --limit-name $useShape --availability-domain $adName --query 'data.available' --raw-output)
clear

if [ -z "$shapeUsage" ]
  then echo "Service limit reached for $cmdShape"
  exit
fi

if [ $shapeUsage -gt 0 ]
then
  echo "Chosen shape: $SHAPE"
  echo "Available: $shapeUsage"
  echo
  echo "The command to be executed would look something like this:"
  echo
  echo "oci compute instance launch --availability-domain <your AD name> --display-name demo-instance --image-id <ID from previous step> --subnet-id <subnet OCID> --shape $SHAPE --compartment-id $CID --assign-public-ip true"
fi



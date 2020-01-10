#!/bin/bash

usage="\n$(basename "$0") [-h] [-s SHAPE] [-c COMPARTMENT] -- launch new compute instance
\n
\nwhere:
\n -h show this help text
\n -s define instance shape
\n -c set compartment OCID
\n"

while getopts 'hs:c:' option; do
  case "${option}" in
    h) echo -e $usage
        exit
        ;;
    s) SHAPE=${OPTARG};;
    c) CID=${OPTARG};;
  esac
done

if [ -z "$CID" ]
then 
  CID="ocid1.compartment.oc1..aaaaaaaav4x6vgcs757ijx7nwyun773mqqlq3p5xmictf2xfnc6k7z25pu3q"
fi

if [ -z "$SHAPE" ]
then
  echo "You must specify a shape"
  exit
else
  cmdShape=$(echo "${SHAPE,,}" | sed -e 's/\./-/g')-count
fi

shapeUsage=$(oci limits resource-availability get --service-name compute -c $CID --limit-name $cmdShape --availability-domain nHRu:PHX-AD-1 --query 'data.available' --raw-output)
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



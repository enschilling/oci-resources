#!/bin/bash

tenancy_ocid="<enter tenancy ocid here>"
identifier="<enter label here>"

for i in {3..30}; do
  # Get the length of the current value of 'i'
  length=${#i}

  echo "Iteration: $i, Length of i: $length"

  if [[ $length -eq 1 ]]; then
    my_string="0$i"
    echo $my_string
  else
    my_string=$i
    echo $my_string
  fi

  # Create compartments
  oci iam compartment create \
    --compartment-id $tenancy_ocid \
    --name $identifier$my_string \
    --description "Dedicated compartment for $identfier group $my_string"

  # Create Groups
  group_ocid=`oci iam group create --name "$identifier$my_string" --description "This group is for $identifier team $my_string" \
    --compartment-id $tenancy_ocid --query 'data.id' --raw-output`

  # Create IAM Policies
  oci iam policy create \
    --compartment-id $tenancy_ocid \
    --name Policy-$identifier$my_string \
    --description "Allows $identifier group$my_string to manage all resources in $identifier$my_string" \
    --statements '["Allow group '$identifier$my_string' to manage all-resources in compartment '$ientifier$my_string'"]'

  # Create IAM Users and add to respective group
  user_ocid=`oci iam user create --name "$identifier$my_string" --email "<your email address here>" --description "This is the IAM user for $identifier group $my_string" --query 'data.id' --raw-output`
  oci iam group add-user --group-id $group_ocid --user-id $user_ocid

echo "Waiting 5 seconds before next loop"
sleep 5

done

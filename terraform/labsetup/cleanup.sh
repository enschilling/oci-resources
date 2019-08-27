#!/bin/bash 
COUNTER=0
  while [  $COUNTER -lt 20 ]; do

  terraform taint oci_identity_user.training_users_phx.$COUNTER
  terraform taint oci_identity_user.training_users_iad.$COUNTER
  terraform taint oci_identity_user.training_users_fra.$COUNTER
  terraform taint oci_identity_user.training_users_lhr.$COUNTER
  terraform taint oci_identity_user.training_users_yyz.$COUNTER
  terraform taint oci_identity_policy.training_user_policy_nas.$COUNTER
  terraform taint oci_identity_policy.training_user_policy_lhr.$COUNTER
  terraform taint oci_identity_policy.training_user_policy_fra.$COUNTER
  terraform taint oci_identity_policy.training_user_policy_yyz.$COUNTER
  #terraform taint oci_identity_ui_password.training_user_passwords_iad.$COUNTER

  let COUNTER=COUNTER+1 
done

######################################################
# List all public IP addresses for compute           #
# instances within a compartment / region            #
#                                                    #
# TODO:                                              #
# - ability to loop through all regions              #
# - ability to specify compartment at runtime        #
# - ability to pass credential profile at runtime    #
# - Find public IP related to secondary prinvate IP  #
#                                                    #
# Last Update: 8/27/2019                             #
# Author: eli.schilling@oracle.com                   #
#                                                    #
######################################################

# Gather all instance IDs into an array
instanceIds=($(oci compute instance list --query 'data[*].id' | sed s'/[\[",]//g' | sed -e 's/\]//g'))

# Loop instances array to find instance name and IP addresses
for i in "${instanceIds[@]}"; do
  unset pubIps
  instName=$(oci compute instance get --instance-id $i --query 'data."display-name"')

  # Find all VNIC attachments for the current compute instance
  vnicAttach=($(oci compute vnic-attachment list --query "data[?\"instance-id\"=='${i}'].\"vnic-id\"" | sed s'/[\[",]//g' | sed -e 's/\]//g'))

  # Loop through all VNIC IDs found in VNIC-ATTACHMENT and locate public IPs
  for v in "${vnicAttach[@]}"; do
    pubIps+=($(oci network vnic get --vnic-id $v --query 'data."public-ip"' --raw-output 2> /dev/null))
  done

  # Decide how to display the results depending on how many IP addresses we find
  if [ ${#pubIps[@]} -eq 0 ]; then
    printf '%s %s - %s\n' "Instance Name - Public IP(s): " "$instName" "No public IPs"
  elif [ ${#pubIps[@]} -eq 1 ]; then
    printf '%s %s - %s\n' "Instance Name - Public IP(s): " "$instName" "${pubIps[@]}"
  else
    echo "Instance Name: - Public IP(s): $instName - ${pubIps[*]}"
    echo ""
  fi
done

# THE END
#
#
# .....no really...you can stop reading now!

### Script Start ###
unset REGION SOURCE DESTINATION PROFILE
counter=0

usage="\n$(basename "$0") [-h] [-s SOURCE] [-d DESTINATION] [-r REGION] [-p PROFILE]\n
\n Move all non-primary secondary IP addresses from one instance to another.
\n
\nwhere:
\n  -h show this help text
\n  -s specify the source VNIC ID [REQUIRED]
\n  -d specify the destination VNIC ID [REQUIRED]
\n  -r set the region (default is region defined ~/.oci/config)
\n  -p set the CLI profile to use
\n"

while getopts 'hs:d:p:r:' option; do
  case "${option}"  in
    h) echo -e $usage
       exit
       ;;
    s) SOURCE=${OPTARG};;
    d) DESTINATION=${OPTARG};;
    p) PROFILE=${OPTARG};;
    r) REGION=${OPTARG};;
  esac
done

if [ -z "$SOURCE" ] || [ -z "$DESTINATION" ]
  then
    echo "You must specify [ -s SOURCE ] and [ -d DESTINATION ] in order to run this script.  There is nothing more I can do"
    echo ""
    exit 0
fi

if [ -z "$PROFILE" ]
  then
    PROFILE="default"
fi

if [ -z "$REGION" ]
  then
    REGION=""
  else
    REGION="--region $REGION"
fi

start=`date +%s`

# gather list of source IPs (is-primary = false)
privIps=($(oci network private-ip list --vnic-id $SOURCE --query 'data[?"is-primary" == `false`]."ip-address"' | sed s'/[\[",]//g' | sed -e 's/\]//g'))

# loop through private IPs and assign to destination NIC
for i in "${privIps[@]}"; do
  counter=$((counter+1))
  echo "$Assigning IP: $i"
  oci network vnic assign-private-ip --vnic-id $DESTINATION --ip-address $i --unassign-if-already-assigned &> /dev/null
done

end=`date +%s`
runtime=$((end-start))

echo "Moved $counter IP addresses in $runtime seconds"

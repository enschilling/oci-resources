### Script Start ###
unset VNICID
counter=0

usage="\n$(basename "$0") [-h] [-v VNICID]\n
\n Loop through all compartments in tenancy to find VNIC host
\n
\nwhere:
\n  -h show this help text
\n  -v specify the VNIC ID [REQUIRED]
\n"

while getopts 'hv:' option; do
  case "${option}"  in
    h) echo -e $usage
       exit
       ;;
    v) VNICID=${OPTARG};;
  esac
done

if [ -z "$VNICID" ]
  then
    echo "You must specify [ -v VNICID ] in order to run this script.  There is nothing more I can do"
    echo ""
    exit 0
fi

start=`date +%s`

# gather list of compartment IDs
compIds=($(oci iam compartment list --query 'data[?"lifecycle-state" == `ACTIVE`].id' |  sed s'/[\[",]//g' | sed -e 's/\]//g'))

# loop through compartment ID's looking for VNIC
for i in "${compIds[@]}"; do
  counter=$((counter+1))
# Locate attached Instance
#  oci compute vnic-attachment list --compartment-id $i --query 'data[?"vnic-id"==`${VNICID}`]."instance-id"

# Locate specific VNIC
oci network vnic get --vnic-id $VNICID --compartment-id $i

done

end=`date +%s`
runtime=$((end-start))

echo "Searched $counter compartments in $runtime seconds"

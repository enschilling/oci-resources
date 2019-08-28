unset REGION BUCKET PROFILE

usage="\n$(basename "$0") [-h] [-b BUCKET] [-r REGION] [-p PROFILE] -- Remove expired pre-authenticated requests from a bucket
\n
\nwhere:
\n  -h show this help text
\n  -b specify the bucket name [REQUIRED]
\n  -r set the region (default is region defined ~/.oci/config)
\n  -p set the CLI profile to use
\n"
	
while getopts 'hb:p:r:' option; do
  case "${option}"  in
    h) echo -e $usage
       exit
       ;;
    b) BUCKET=${OPTARG};;
    p) PROFILE=${OPTARG};;
    r) REGION=${OPTARG};;
  esac
done

if [ -z "$BUCKET" ]
  then
    echo "-b BUCKET is a required parameter.  There is nothing more I can do"
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

thisdate=$(date -d '+9 hour' +"%Y-%m-%d %H:%M")
parIds=$(oci os preauth-request list -bn $BUCKET $REGION --query "data[?\"time-expires\" < '$thisdate']|[0].id" --raw-output 2> /dev/null)

[[ -z "$parIDS" ]] || echo "No expired PARs in the designated bucket."

while [ ! -z "$parIds" ]
  do
    echo "Preparing to delete: " $parIds
    sleep 10 #this can be commented out - included only for validation purposes
    oci os preauth-request delete -bn $BUCKET $REGION --par-id "$parIds" --force
    sleep 5
    parIds=$(oci os preauth-request list -bn $BUCKET $REGION --query "data[?\"time-expires\" < '$thisdate']|[0].id" --raw-output 2> /dev/null)
    [[ ! -z $parIds ]] || unset parIds
done

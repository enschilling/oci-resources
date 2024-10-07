#!/bin/bash


usage="\n$(basename "$0") [-h] [-s SHAPE] [-r REGION] [-o ORDER] -- find available GPU capacity
\n
\nwhere: 
\n -h show this help text
\n -s define instance shape (e.g. VM.GPU.A10.1)
\n -r specificy a single region to check (e.g. us-ashburn-1)
\n -o specify order: ad = crawl availability domains | shape = display by shape
\n
\n **If a region is not specified, we will search all subscribed regions
\n"

while getopts 'hs:r:' option; do
  case "${option}" in
    h) tenancyId=($(oci iam availability-domain list --query 'data[0]."compartment-id"' | sed s'/[\[",]//g' | sed -e 's/\]//g'))
        shapeList=($(oci limits definition list -c $tenancyId --all --query 'data[?contains("service-name", `compute`)]|[?contains("description", `GPU`)]|[? !contains("name", `reserv`)].name' | sed s'/[\[",]//g' | sed -e 's/\]//g'))
        echo -e $usage
        echo "======== list of GPU shapes ========"
        for s in "${shapeList[@]}"; do
          echo $s
        done
        exit
        ;;
    s) SHAPE=${OPTARG};;
    r) REGION=${OPTARG};;
    o) ORDER=${OPTARG};;
  esac
done

#Retrieve tenancy OCID
tenancyId=($(oci iam availability-domain list --query 'data[0]."compartment-id"' | sed s'/[\[",]//g' | sed -e 's/\]//g'))


if [ -z "$REGION" ]
then
  echo "You didn't enter a specific region, let's check them all!"
  regList=($(oci iam region-subscription list --query 'data[? !contains("region-name", `dallas`)]|[? !contains("region-name", `saltlake`)]."region-name"' | sed s'/[\[",]//g' | sed -e 's/\]//g'))
  # delete non-replicated regions. For now, this value is hard-coded.

else
  regList=$REGION
fi

if [ -z "$ORDER" ]
then
  # default sort / group order is set to shape
  ORDER="SHAPE"
fi

#Print details of the activity and prompt for confirmation
clear
echo -e "\n========================================================="
echo -e "\nNow checking capacity in the following regions: " && printf '%s,' "${regList[@]}"
echo ""
read -p "Would you like to continue? " -n 1 -r
echo 

if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Ok - here we go!"
else
  exit 1
fi

start_time=$(date +%s)

case $ORDER in

AD)
    for r in "${regList[@]}"; do
    echo "Region: " $r

    #Get AD(s)
    adList=($(oci iam availability-domain list --region $r --query 'data[*].name' | sed s'/[\[",]//g' | sed -e 's/\]//g'))

    #Get GPU-related resource names if a specific shape was not entered
    if [ -z "$SHAPE" ]
    then
        shapeList=($(oci limits definition list --region $r -c $tenancyId --service-name compute --all --query 'data[?contains("description", `GPU`)]|[? !contains("name", `reserv`)].name' | sed s'/[\[",]//g' | sed -e 's/\]//g'))
    else
        shapeList=$SHAPE
    fi
    
    for a in "${adList[@]}"; do
        echo "AD name: " $a

        for s in "${shapeList[@]}"; do
        shapeCapacity=($(oci limits resource-availability get --region $r --service-name compute -c $tenancyId --limit-name $s --availability-domain $a --query 'data.available' --raw-output))
        echo "Capacity for " $s ": " $shapeCapacity
        done

    done

    echo " "

    done
;;

SHAPE)
    shapeList=($(oci limits definition list -c $tenancyId --service-name compute --all --query 'data[?contains("description", `GPU`)]|[? !contains("name", `reserv`)].name' | sed s'/[\[",]//g' | sed -e 's/\]//g'))

    for s in "${shapeList[@]}"; do
        echo "Capacity for shape: " $s
        ((shapeCount++))

        for r in "${regList[@]}"; do

            ((regionCount++))

            #Get AD(s)
            adList=($(oci iam availability-domain list --region $r --query 'data[*].name' | sed s'/[\[",]//g' | sed -e 's/\]//g'))

            for a in "${adList[@]}"; do
                ((adCount++))
                shapeCapacity=($(oci limits resource-availability get --region $r --service-name compute -c $tenancyId --limit-name $s --availability-domain $a --query 'data.available' --raw-output))
                echo $s " available in " $a ": " $shapeCapacity
            done
        done
        echo " --- "
        echo ""
    done
;;

esac

end_time=$(date +%s)
runtime=$((end_time - start_time))

echo "Checked $shapeCount shapes in $adCount ADs across $regionCount regions."
echo "Total script runtime: $runtime seconds."
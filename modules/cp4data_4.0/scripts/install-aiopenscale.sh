#!/bin/bash

wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-watson-openscale-2.0.0.tgz

# Install WOS operator using CLI (OLM)

CASE_PACKAGE_NAME="ibm-watson-openscale-2.0.0.tgz"

oc project ${OP_NAMESPACE}


./cloudctl-linux-amd64 case launch --case ./${CASE_PACKAGE_NAME} \
    --namespace ${OP_NAMESPACE}                                   \
    --tolerance 1

# Checking if the wos operator pods are ready and running. 

# ./pod-status-check.sh ibm-cpd-wos-operator ${OP_NAMESPACE}
sleep 10m

# switch zen namespace

oc project ${NAMESPACE}

cd ../files

# Create wsl CR:

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" openscale-cr.yaml
fi

result=$(oc create -f openscale-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status

# ./check-cr-status.sh WOService aiopenscale ${NAMESPACE} wosStatus
sleep 10m
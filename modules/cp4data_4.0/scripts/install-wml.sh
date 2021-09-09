#!/bin/bash

# Case package. 

wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-wml-cpd-4.0.0.tgz

# # Install wml operator using CLI (OLM)


CASE_PACKAGE_NAME="ibm-wml-cpd-4.0.0.tgz"

export WML_OPERATOR_CATALOG_NAMESPACE=openshift-marketplace


## Install catalog 

./cloudctl-linux-amd64 case launch --case ${CASE_PACKAGE_NAME} \
    --namespace ${WML_OPERATOR_CATALOG_NAMESPACE}  \
    --inventory  wmlOperatorSetup \
    --action installCatalog \
    --tolerance 1

## Install Operator

./cloudctl-linux-amd64 case launch --case ${CASE_PACKAGE_NAME} \
    --namespace ${OP_NAMESPACE} \
    --inventory  wmlOperatorSetup \
    --action install \
    --tolerance=1

# Checking if the wml operator pods are ready and running. 

# checking status of ibm-watson-wml-operator

# ./pod-status-check.sh ibm-cpd-wml-operator ${OP_NAMESPACE}
sleep 10m

# switch zen namespace

oc project ${NAMESPACE}

cd ../files

# Create wml CR: 

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" wml-cr.yaml
    sed -i -e "/storageVendor/d" wml-cr.yaml #storageVendor
fi

echo '*** executing **** oc create -f wml-cr.yaml'
result=$(oc create -f wml-cr.yaml)
echo $result

cd ../scripts

# check the WML cr status

# ./check-cr-status.sh WmlBase wml-cr ${NAMESPACE} wmlStatus
sleep 10m
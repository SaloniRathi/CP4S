#!/bin/bash


# Case package.
wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-cde-2.0.0.tgz

CASE_PACKAGE_NAME="ibm-cde-2.0.0.tgz"

## Install Operator

./cloudctl-linux-amd64 case launch \
  --case ${CASE_PACKAGE_NAME} \
  --namespace ${OP_NAMESPACE} \
  --tolerance=1 \
  --action installOperator \
  --inventory cdeOperatorSetup



# Checking if the cde operator pods are ready and running. 
# checking status of ibm-cde-operator
# ./pod-status-check.sh ibm-cde-operator ${OP_NAMESPACE}
sleep 10m

# switch to zen namespace
oc project ${NAMESPACE}

# Create cde CR:

cd ../files

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" cde-cr.yaml
fi

sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" cde-cr.yaml
echo '*** executing **** oc create -f cde-cr.yaml'
result=$(oc create -f cde-cr.yaml)
echo $result

cd ../scripts

# check the cde cr status
# ./check-cr-status.sh CdeProxyService cde-cr ${NAMESPACE} cdeStatus
sleep 10m
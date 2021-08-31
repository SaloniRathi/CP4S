#!/bin/bash


# Install ccs operator

wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-ccs-1.0.0.tgz


CASE_PACKAGE_NAME="ibm-ccs-1.0.0.tgz"

wget https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-darwin-amd64.tar.gz
wget https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-darwin-amd64.tar.gz.sig
tar -xvf cloudctl-linux-amd64.tar.gz
echo '*** ccs Seeing if cloudctl binary path works ***'


./cloudctl-linux-amd64 case launch --case ./${CASE_PACKAGE_NAME} \
    --tolerance 1 --namespace ${OP_NAMESPACE}         \
    --action installOperator                        \
    --inventory ccsSetup                            


# Checking if the ccs operator pods are ready and running. 

# checking status of ibm-cpc-ccs-operator

# ./pod-status-check.sh ibm-cpd-ccs-operator ${OP_NAMESPACE}
sleep 5m

# switch zen namespace

oc project ${NAMESPACE} 

cd ../files

# Create CCS CR: 

echo '*** executing **** oc create -f ccs-cr.yaml'
result=$(oc create -f ccs-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status

# ./check-cr-status.sh ccs ccs-cr ${NAMESPACE}  ccsStatus
sleep 5m

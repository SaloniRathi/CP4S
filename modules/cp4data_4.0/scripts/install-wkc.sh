#!/bin/bash

#Create directory

# Copy the required yaml files for wkc setup .. 
cd wkc-files

# Case package. 

# wkc case package 
wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-wkc-4.0.0.tgz

# ## IIS case package 
wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-iis-4.0.0.tgz


CASE_PACKAGE_NAME="ibm-wkc-4.0.0.tgz"

## Install Operator

./../cloudctl-linux-amd64 case launch --case  ${CASE_PACKAGE_NAME} \
    --tolerance 1 \
    --namespace ${OP_NAMESPACE} \
    --action installOperator \
    --inventory wkcOperatorSetup

# Checking if the wkc operator pods are ready and running. 

./../pod-status-check.sh ibm-cpd-wkc-operator ${OP_NAMESPACE}

# switch to zen namespace

oc project ${NAMESPACE}


# # Install wkc Customer Resource

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" wkc-cr.yaml #storage_class_name
    sed -i -e "s/portworx/ibm/g" wkc-cr.yaml #storageVendor
fi

#sed -i -e "s/REPLACE_STORAGECLASS/${local.cpd-storageclass}/g" wkc-cr.yaml
echo '*** executing **** oc create -f wkc-cr.yaml'
result=$(oc create -f wkc-cr.yaml)
echo $result

# check the wkc cr status
./../check-cr-status.sh wkc wkc-cr ${NAMESPACE} wkcStatus

## IIS cr installation 

sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" wkc-iis-scc.yaml
echo '*** executing **** oc create -f wkc-iis-scc.yaml'
result=$(oc create -f wkc-iis-scc.yaml)
echo $result

# Install IIS operator using CLI (OLM)

CASE_PACKAGE_NAME="ibm-iis-4.0.0.tgz"

## Install Operator

./../cloudctl-linux-amd64 case launch --case  ${CASE_PACKAGE_NAME} \
    --tolerance 1 \
    --namespace ${OP_NAMESPACE} \
    --action installOperator \
    --inventory iisOperatorSetup

# Checking if the wkc iis operator pods are ready and running. 
# checking status of ibm-cpd-iis-operator
./../pod-status-check.sh ibm-cpd-iis-operator ${OP_NAMESPACE}

# switch to zen namespace

oc project ${NAMESPACE}

# # Install wkc Customer Resource

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" wkc-iis-cr.yaml #storage_class_name
    sed -i -e "s/portworx/ibm/g" wkc-iis-cr.yaml #StorageVendor
fi

sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" wkc-iis-cr.yaml
echo '*** executing **** oc create -f wkc-iis-cr.yaml'
result=$(oc create -f wkc-iis-cr.yaml)
echo $result

# check the wkc cr status
./../check-cr-status.sh iis iis-cr ${NAMESPACE} iisStatus

# switch to zen namespace

oc project ${NAMESPACE}

# # Install wkc Customer Resource

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx/ibm/g" wkc-ug-cr.yaml #storageVendor
fi

echo '*** executing **** oc create -f wkc-ug-cr.yaml'
result=$(oc create -f wkc-ug-cr.yaml)
echo $result

# check the wkc cr status
./../check-cr-status.sh ug ug-cr ${NAMESPACE} ugStatus
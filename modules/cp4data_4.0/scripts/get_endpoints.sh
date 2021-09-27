#!/bin/bash

eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

# Obtains the credentials and endpoints for the installed CP4I Dashboard
results() {
  console_url_address=$1
  password=$2
  username=$3

  # NOTE: The credentials are static and defined by the installer, in the future this
  # may not be the case.
  # username="admin"

  jq -n \
    --arg endpoint "$console_url_address" \
    --arg username "$username" \
    --arg password "$password" \
    '{ "endpoint": $endpoint, "username": $username, "password": $password }'

  exit 0
}

#route=$(oc get route -n zen cpd -o jsonpath={.spec.host} && echo)
route=$(oc get route -n ${NAMESPACE} cpd -o jsonpath='{.spec.host}' && echo)
# pass=$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo)
# pass=$(oc -n zen get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d && echo)
pass=$(oc -n ${NAMESPACE} get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d && echo)
# pass=$(oc extract secret/admin-user-details --keys=initial_admin_password --to=- -n ${NAMESPACE})
# user=$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d && echo)
user="admin"

results "${route}" "${pass}" "${user}"

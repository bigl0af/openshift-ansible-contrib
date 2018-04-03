#!/bin/bash

warnuser(){
  cat << EOF
###########
# WARNING #
###########
This script is distributed WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND
Beware ImageStreams objects are not importables due to the way they work
See https://github.com/openshift/openshift-ansible-contrib/issues/967
for more information
EOF
}

die(){
  echo "$1"
  exit $2
}

usage(){
  echo "$0 <projectdirectory>"
  echo "  projectdirectory  The directory where the exported objects are hosted"
  echo "Examples:"
  echo "    $0 ~/backup/myproject"
  warnuser
}

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]
then
  usage
  die "Missing project directory" 3
fi

for i in oc
do
  command -v $i >/dev/null 2>&1 || die "$i required but not found" 3
done

warnuser
#read -p "Are you sure? " -n 1 -r
#echo    # (optional) move to a new line
#if [[ ! $REPLY =~ ^[Yy]$ ]]
#then
#    die "User cancel" 4
#fi

PROJECTPATH=$1
SRC_PROJECT=$(jq -r .metadata.name ${PROJECTPATH}/ns.json)
TGT_PROJECT=$SRC_PROJECT

if [ -n "$2" ]; then
  TGT_PROJECT="$2"
  echo "Importing into project ${TGT_PROJECT}"
fi

$(oc get projects -o name | grep "^projects/${TGT_PROJECT}\$" -q) && \
  die "Project ${TGT_PROJECT} exists" 4

jq ".metadata.name = \"${TGT_PROJECT}\"" ${PROJECTPATH}/ns.json | oc create -f -
sleep 2

# First we create optional objects
for object in limitranges resourcequotas
do
  [[ -f ${PROJECTPATH}/${object}.json ]] && \
    jq ".metadata.namespace = \"${TGT_PROJECT}\"" ${PROJECTPATH}/${object}.json | \
    oc create -f - -n ${TGT_PROJECT}
done

[[ -f ${PROJECTPATH}/rolebindings.json ]] && \
  jq ".metadata.namespace = \"${TGT_PROJECT}\"" ${PROJECTPATH}/rolebindings.json | \
  jq ".subjects[].namespace = \"${TGT_PROJECT}\"" | \
  jq ".userNames = [.userNames[]? | sub(\"${SRC_PROJECT}\"; \"${TGT_PROJECT}\")]" | \
  jq ".groupNames = [.groupNames[]? | sub(\"${SRC_PROJECT}\"; \"${TGT_PROJECT}\")]" | \
  oc create -f - -n ${TGT_PROJECT}

for object in rolebindingrestrictions secrets serviceaccounts podpreset poddisruptionbudget templates cms egressnetworkpolicies iss imagestreams pvcs routes hpas
do
  [[ -f ${PROJECTPATH}/${object}.json ]] && \
    jq ".metadata.namespace = \"${TGT_PROJECT}\"" ${PROJECTPATH}/${object}.json | \
    oc create -f - -n ${TGT_PROJECT}
done

# Services & endpoints
for svc in ${PROJECTPATH}/svc_*.json
do
  oc create -f ${svc} -n ${TGT_PROJECT}
done
for endpoint in ${PROJECTPATH}/endpoint_*.json
do
  epfile=$(echo ${endpoint##*/})
  EPNAME=$(echo ${epfile} | sed "s/endpoint_\(.*\)\.json$/\1/")
  echo "Checking ${EPNAME}"
  if ! oc get endpoints ${EPNAME} -n ${TGT_PROJECT} >/dev/null 2>&1; then
    jq ".subsets[].addresses[].targetRef.namespace = \"${TGT_PROJECT}\"" ${endpoint} | \
      oc create -f - -n ${TGT_PROJECT}
  fi
done

# More objects, this time those can create apps
[[ -f ${PROJECTPATH}/bcs.json ]] && \
  oc create -f ${PROJECTPATH}/bcs.json -n ${TGT_PROJECT}

[[ -f ${PROJECTPATH}/builds.json ]] && \
  jq ".status.config.namespace = \"${TGT_PROJECT}\"" ${PROJECTPATH}/builds.json | \
  oc create -f - -n ${TGT_PROJECT}

# Restore DCs
# If patched exists, restore it, otherwise, restore the plain one
for dc in ${PROJECTPATH}/dc_*.json
do
  dcfile=$(echo ${dc##*/})
  [[ ${dcfile} == dc_*_patched.json ]] && continue
  DCNAME=$(echo ${dcfile} | sed "s/dc_\(.*\)\.json$/\1/")
  if [ -s ${PROJECTPATH}/dc_${DCNAME}_patched.json ]
  then
    oc create -f ${PROJECTPATH}/dc_${DCNAME}_patched.json -n ${TGT_PROJECT}
  else
    oc create -f ${dc} -n ${TGT_PROJECT}
  fi
done

for object in replicasets deployments
do
  [[ -f ${PROJECTPATH}/${object}.json ]] && \
    jq ".metadata.namespace = \"${TGT_PROJECT}\"" ${PROJECTPATH}/${object}.json | \
    oc create -f - -n ${TGT_PROJECT}
done

for rc in ${PROJECTPATH}/rc_*.json
do
  rcfile=$(echo ${rc##*/})
  RCNAME=$(echo ${rcfile} | sed "s/rc_\(.*\)\.json$/\1/")
  echo "Checking ${RCNAME}"
  if ! oc get rc ${RCNAME} -n ${TGT_PROJECT} >/dev/null 2>&1; then
    oc create -f ${rc} -n ${TGT_PROJECT} 
  fi
done

for object in pods cronjobs statefulsets daemonset
do
  [[ -f ${PROJECTPATH}/${object}.json ]] && \
    jq ".metadata.namespace = \"${TGT_PROJECT}\"" ${PROJECTPATH}/${object}.json | \
    oc create -f - -n ${TGT_PROJECT}
done

[[ -f ${PROJECTPATH}/pvcs_attachment.json ]] &&
  echo "There are pvcs objects with attachment information included in the ${PROJECTPATH}/pvcs_attachment.json file, remove the current pvcs and restore them using that file if required"

exit 0

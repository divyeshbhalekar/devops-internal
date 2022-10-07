#/bin/bash
# This script will clone the repo from GitHub and create template of HELM Chart
# After that it will slice the  generated manifest to make it easier to get manifest from the desire cluster
# Desire Cluster=which cluster you want to use for comparision of manifest (DEV, QA, Prod)

# list of services
declare -a arr=("aws-soc2" "aethia" "audit-scan-manager" "aws-all-activity-log" "aws-cis" "aws-cloud-logs" "aws-cloudmap-dump" "aws-cloudmap-fetch" "aws-data-submission" "aws-discovery" "aws-discovery-v2-dump" "aws-discovery-v2-fetch" "aws-dlp" "aws-dlp-file-parse" "aws-iso-27001" "aws-iso-27001-manager" "aws-manager" "aws-nist-800-171" "aws-nist-800-171-manager" "aws-nist-800-53" "aws-nist-800-53-manager" "aws-pcidss" "aws-pcidss-manager" "aws-resourceids" "aws-soc2-manager" "azure-all-activity-log" "azure-ccm4" "azure-ccm4-manager" "azure-cis" "azure-cis-resourceids" "azure-cloud-scan" "azure-cosmos" "azure-database-audit" "azure-dlp-file-parse" "azure-hitrust" "azure-hitrust-manager" "azure-iso-27001" "azure-iso-manager" "azure-manager" "azure-nist-800-171" "azure-nist-800-171-manager" "azure-nist-800-53-manager" "azure-pcidss" "azure-pcidss-manager" "azure-rds" "azure-soc2" "azure-soc2-manager" "azure-vm-snapshot" "cloud-assets-discovery" "cloud-audit-manager" "cloud-compliance-report" "cloud-manager" "common-malware-scan" "common-policy-engine" "common-vulnerability-scan" "dlp-api" "dlp-backend" "dlp-classification-submitter" "dlp-k8s-manager" "dlp-publisher" "dlp-scanner" "dlp-serivce" "email-integration" "event-listener" "gatekeeper-manager" "gcp-all-activity-log" "gcp-big-query" "gcp-cis" "gcp-cloud-scan" "gcp-cloud-sql" "gcp-dlp" "gcp-dlp-file-parse" "gcp-firestore" "gcp-manager" "gcp-mongo" "gcp-nist-800-171" "gcp-nist-800-171-manager" "gcp-nist-800-53" "gcp-nist-800-53-managerr" "gcp-resourceids" "gcp-soc2" "gcp-soc2-manager" "gcp-vm-snapshot" "gcp-vm-snapshoting" "ibm-cloud-scan" "ibm-datastax" "ibm-db2" "ibm-edb" "ibm-elasticsearch" "ibm-mongodb" "ibm-postgres" "image-analyzer" "jira-integration" "kiali-client" "kiali-dlp" "kiali-ui" "kubernetes-manager" "microsec-agent-manager" "microsec-audit-report" "microsec-bop" "microsec-frontend" "microsec-frontend-backend" "microsec-pci" "microsec-risk-assessment" "msec" "postgresdb" "redwoods" "slack-integration")
for i in "${arr[@]}"
do
    git clone https://github.com/microsec-ai/$i.git
    # change values file for QA and Prod
    helm template -f $i/charts/dev-values.yaml $i $i/charts/  > $i.yaml
    if [ "$?" -eq 1 ]; then
        rm $i.yaml
        continue
    fi
    #  https://github.com/patrickdappollonio/kubectl-slice#installation
    kubectl-slice -f $i.yaml  -o ./$i-manifest >>file.log 2>&1
    rm $i.yaml
    #conver to JSON because YAML comaprision sometime is not feasible because of redundant spaces
    for entry in "$i-manifest"/*
    do
        yq -j "$entry" -o json > "$entry"-bb
        mv "$entry"-bb "$entry"
    done
    # get manifest from Deployed Cluster to match and find diff
    # removed extra fields that are not required
    for entry in "$i-manifest"/*
    do
        manifestType=$(basename "$entry" .yaml |cut -d '-' -f1)
        kubectl get ${manifestType} -n microsec-system ${i} -o json | jq  'del(.metadata.managedFields)' | \
        jq  'del(.status)' | \
        jq  'del(.metadata.creationTimestamp)' |  \
        jq  'del(.metadata.generation)'  | \
        jq  'del(.metadata.resourceVersion)'| \
        jq  'del(.metadata.uid)' | \
        jq  'del(.metadata.annotations)' | \
        jq  'del(.spec.schedulerName)' | \
        jq  'del(.spec.terminationGracePeriodSeconds)' | \
        jq  'del(.spec.template.metadata.creationTimestamp)'|\
        jq  'del(.spec.template.metadata.annotations."keel.sh/update-time")'|\
        jq  'del(.metadata.labels."app.kubernetes.io/managed-by")' |\
        jq  'del(.metadata.annotations)' | \
        jq  'del(.metadata.creationTimestamp)' | \
        jq  'del(.metadata.generation)' | \
        jq  'del(.metadata.resourceVersion)' | \
        jq 'del(.metadata.uid)' | \
        jq 'del(.metadata.managedFields)' | \
        jq 'del(.spec.clusterIP)' | \
        jq 'del(.spec.clusterIPs)' | \
        jq 'del(.status)' | \
        jq 'del(.spec.ipFamilies)' | \
        jq 'del(.spec.ipFamilyPolicy)' | \
        #jq 'del(.spec.sessionAffinity)' | \
        jq 'del(.metadata.labels."app.kubernetes.io/managed-by")'   > "${i}-manifest"/${manifestType}.json
        diff -u ${entry} "${i}"-manifest/"${manifestType}".json  >> "${i}-manifest"/result.diff
    done
done

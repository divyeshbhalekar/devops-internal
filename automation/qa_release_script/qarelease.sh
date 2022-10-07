declare -a arr=("aws-cloud-storage" "azure-cloud-storage" "gcp-cloud-storage" "dlp-response-handler-publisher" "dlp-response-handler" "dlp-info" "scan-report" "aws-dlp-file-parse" "azure-dlp-file-parse" "gcp-dlp-file-parse" "common-submitter" "alerts-storage" "file-malware-scan" "azure-cloud-scan" "dlp-api" "common-policy-engine" "aws-cloud-logs" "aws-manager" "azure-manager" "gcp-manager" "dlp-manager" "gatekeeper-manager" "microsec-frontend" "microsec-backend")
for i in "${arr[@]}"
do
    git clone https://github.com/microsec-ai/$i.git && \
    cd $i && \
    git tag qa-v1.25.0 HEAD -m "sprint 25 release" && \
    git push --tags && \
    cd ..
done

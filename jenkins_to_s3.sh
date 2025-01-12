#!/bin/bash
#
# Author: Vandan Savla
# Description: Uploads Jenkins build logs to s3 buckets for cost optimization
#

# Variables
JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="s3://jenkins-logs-bucket-vds"
DATE=$(date +%Y-%m-%d)  # Today's date

if ! command -v aws &> /dev/null; then
	echo "AWS is not installed Please install it."
	exit 1
fi

# Iterate through all job directories

for job_dir in "$JENKINS_HOME/jobs/"*/; do
	job_name=$(basename "$job_dir")

	# Get build number and log file path 
	for build_dir in "$job_dir/builds/"*/; do 
		build_number=$(basename "$build_dir")
		log_file="$build_dir/log"
		if [ -f "$log_file" ] && [ "$(date -r "$log_file" +%Y-%m-%d)" == "$DATE" ]; then
			s3_job_folder="$S3_BUCKET/$job_name"
			aws s3 cp "$log_file" "$s3_job_folder/$build_number.log" --only-show-errors

			if [ $? -eq 0 ]; then
				echo "Uploaded: $job_name/$build_number to $s3_job_folder/$build_number.log"
			else
				 echo "Failed to upload: $job_name/$build_number"
			fi
		fi
	done
done 


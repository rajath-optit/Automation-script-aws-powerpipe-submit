This script implements EC2 Control 1 for AMI encryption. Here's how to use it:

Save the script as ec2_control1.sh
Make it executable: chmod +x ec2_control1.sh
Run it with one or more AMI IDs:

bashCopy./ec2_control1.sh ami-014345229bebb6f1c ami-0334f14f99df276cd ami-038491f9665358ac2
The script will:

Validate each AMI ID format
Check if each AMI exists and is accessible
Check the encryption status of all EBS volumes in the AMI
For unencrypted AMIs:

Create an encrypted copy
Add tracking tags
Wait for the new AMI to be available


Generate detailed logs of all actions
Provide a summary of processed AMIs

Features:

Detailed logging to a timestamped file
Error handling for invalid AMIs
Progress tracking for multiple AMIs
Waiting for AMI creation to complete
Tagging for tracking original AMIs
Summary report of processed AMIs

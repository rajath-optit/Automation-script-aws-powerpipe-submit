#!/bin/bash

# Set error handling
set -e
set -o pipefail

# Configure logging
LOG_FILE="ec2_control1_ami_encryption_$(date +%Y%m%d_%H%M%S).log"

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to validate AMI ID format
validate_ami_id() {
    local ami_id="$1"
    if [[ ! $ami_id =~ ^ami-[a-zA-Z0-9]+$ ]]; then
        log "ERROR: Invalid AMI ID format: $ami_id"
        return 1
    fi
    return 0
}

# Function to check if AMI exists
check_ami_exists() {
    local ami_id="$1"
    if ! aws ec2 describe-images --image-ids "$ami_id" &>/dev/null; then
        log "ERROR: AMI $ami_id not found or no permission to access"
        return 1
    fi
    return 0
}

# Function to check if AMI is encrypted
check_ami_encryption() {
    local ami_id="$1"
    local encryption_status
    
    log "Checking encryption status for AMI: $ami_id"
    
    # Get the encryption status of all EBS volumes in the AMI
    encryption_status=$(aws ec2 describe-images --image-ids "$ami_id" \
        --query 'Images[0].BlockDeviceMappings[].Ebs.Encrypted' \
        --output text)
    
    # Check if any volume is unencrypted
    if [[ $encryption_status == *"False"* ]]; then
        return 1
    fi
    return 0
}

# Function to create encrypted copy of AMI
create_encrypted_ami() {
    local source_ami="$1"
    local ami_name
    local new_ami_id
    
    # Get the original AMI name
    ami_name=$(aws ec2 describe-images --image-ids "$source_ami" \
        --query 'Images[0].Name' --output text)
    
    log "Creating encrypted copy of AMI $source_ami"
    
    # Create new AMI name with encrypted suffix
    local new_ami_name="${ami_name}-encrypted-$(date +%Y%m%d-%H%M%S)"
    
    # Copy AMI with encryption
    new_ami_id=$(aws ec2 copy-image \
        --source-image-id "$source_ami" \
        --source-region "$(aws configure get region)" \
        --name "$new_ami_name" \
        --encrypted \
        --query 'ImageId' \
        --output text)
    
    log "Started creation of encrypted AMI: $new_ami_id"
    
    # Wait for the AMI to be available
    log "Waiting for encrypted AMI to be available..."
    aws ec2 wait image-available --image-ids "$new_ami_id"
    
    log "Successfully created encrypted AMI: $new_ami_id from $source_ami"
    echo "$new_ami_id"
}

# Main function to process a single AMI
process_ami() {
    local ami_id="$1"
    
    log "Processing AMI: $ami_id"
    
    # Validate AMI ID format
    if ! validate_ami_id "$ami_id"; then
        return 1
    fi
    
    # Check if AMI exists
    if ! check_ami_exists "$ami_id"; then
        return 1
    fi
    
    # Check encryption status
    if ! check_ami_encryption "$ami_id"; then
        log "AMI $ami_id is not encrypted. Creating encrypted copy..."
        local new_ami_id
        new_ami_id=$(create_encrypted_ami "$ami_id")
        log "REMEDIATION COMPLETE: Created encrypted AMI $new_ami_id from $ami_id"
        
        # Add tags to track the original AMI
        aws ec2 create-tags --resources "$new_ami_id" \
            --tags "Key=OriginalAMI,Value=$ami_id" \
            "Key=ComplianceStatus,Value=Encrypted"
    else
        log "AMI $ami_id is already encrypted. No action needed."
    fi
}

# Main execution
main() {
    log "Starting EC2 Control 1 - AMI Encryption Check and Remediation"
    
    # Check if any AMI IDs were provided
    if [ "$#" -eq 0 ]; then
        log "ERROR: No AMI IDs provided"
        echo "Usage: $0 ami-id1 [ami-id2 ...]"
        exit 1
    fi
    
    # Process each AMI ID
    local total_amis=$#
    local processed=0
    local failed=0
    
    for ami_id in "$@"; do
        log "Processing $((processed + 1))/$total_amis: $ami_id"
        if process_ami "$ami_id"; then
            ((processed++))
        else
            ((failed++))
        fi
    done
    
    # Summary
    log "Processing complete:"
    log "Total AMIs processed: $processed"
    log "Failed: $failed"
    log "Check $LOG_FILE for detailed logging"
}

# Execute main function with all provided AMI IDs
main "$@"

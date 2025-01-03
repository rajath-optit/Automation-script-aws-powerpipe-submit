#!/bin/bash

# AWS EBS/EC2 Compliance Automation Script
# Version: 1.0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# EBS Control Functions
ebs_control1() {
    local volume_id=$1
    log "Running EBS Control 1: Checking Delete on Termination flag"
    
    # Check if volume exists
    if aws ec2 describe-volumes --volume-ids "$volume_id" >/dev/null 2>&1; then
        local attachment_state=$(aws ec2 describe-volumes --volume-ids "$volume_id" --query 'Volumes[0].Attachments[0].State' --output text)
        
        if [ "$attachment_state" == "attached" ]; then
            log "Setting Delete on Termination flag for volume $volume_id"
            aws ec2 modify-instance-attribute --instance-id $(aws ec2 describe-volumes --volume-ids "$volume_id" --query 'Volumes[0].Attachments[0].InstanceId' --output text) \
                --block-device-mappings "[{\"DeviceName\": \"$(aws ec2 describe-volumes --volume-ids "$volume_id" --query 'Volumes[0].Attachments[0].Device' --output text)\",\"Ebs\":{\"DeleteOnTermination\":true}}]"
            log "Successfully updated Delete on Termination flag"
        else
            warning "Volume $volume_id is not attached to any instance"
        fi
    else
        error "Volume $volume_id not found"
        return 1
    fi
}

ebs_control2() {
    local volume_id=$1
    log "Running EBS Control 2: Checking Volume Encryption"
    
    # Check encryption status
    local encryption_state=$(aws ec2 describe-volumes --volume-ids "$volume_id" --query 'Volumes[0].Encrypted' --output text)
    
    if [ "$encryption_state" == "false" ]; then
        log "Volume $volume_id is not encrypted. Creating encrypted snapshot..."
        
        # Create snapshot
        local snapshot_id=$(aws ec2 create-snapshot --volume-id "$volume_id" --description "Automated encryption snapshot" --query 'SnapshotId' --output text)
        
        # Wait for snapshot to complete
        aws ec2 wait snapshot-completed --snapshot-ids "$snapshot_id"
        
        # Create new encrypted volume
        log "Creating new encrypted volume from snapshot..."
        local new_volume_id=$(aws ec2 create-volume --snapshot-id "$snapshot_id" --encrypted --volume-type gp3 --availability-zone $(aws ec2 describe-volumes --volume-ids "$volume_id" --query 'Volumes[0].AvailabilityZone' --output text) --query 'VolumeId' --output text)
        
        # Wait for volume to be available
        aws ec2 wait volume-available --volume-ids "$new_volume_id"
        
        log "Successfully created encrypted volume $new_volume_id"
    else
        log "Volume $volume_id is already encrypted"
    fi
}

# Main execution
main() {
    echo "AWS EBS/EC2 Compliance Automation Tool"
    echo "======================================"
    
    # Prompt for resource type
    echo "Select resource type:"
    echo "1) EBS"
    echo "2) EC2"
    read -p "Enter choice (1-2): " resource_choice
    
    case $resource_choice in
        1)
            read -p "Enter EBS Volume ID: " volume_id
            echo "Select control to run:"
            echo "1) Enable Delete on Termination"
            echo "2) Enable Volume Encryption"
            read -p "Enter control number (1-2): " control_choice
            
            case $control_choice in
                1) ebs_control1 "$volume_id" ;;
                2) ebs_control2 "$volume_id" ;;
                *) error "Invalid control selection" ;;
            esac
            ;;
        2)
            echo "EC2 controls coming soon..."
            ;;
        *)
            error "Invalid resource type selection"
            ;;
    esac
}

# Execute main function
main

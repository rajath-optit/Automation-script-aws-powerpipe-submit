#!/bin/bash

# EC2 Compliance Automation Script
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

# Enhanced error handling function
handle_error() {
    local error_message=$1
    local error_code=$2
    echo -e "${RED}[ERROR]${NC} $error_message"
    exit $error_code
}

# Retry command with exponential backoff
retry_command() {
    local command="$1"
    local max_retries=5
    local attempt=1
    local delay=5 # initial delay in seconds

    while [ $attempt -le $max_retries ]; do
        echo -e "${GREEN}[INFO]${NC} Attempt $attempt: Running command '$command'"
        
        # Run the command
        eval "$command"

        # If the command was successful (exit code 0), break the loop
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[INFO]${NC} Command '$command' succeeded on attempt $attempt."
            return 0
        else
            # If the command failed, increment the attempt and apply delay
            echo -e "${YELLOW}[WARNING]${NC} Command '$command' failed. Retrying in $delay seconds..."
            sleep $delay
            ((attempt++))
            delay=$((delay * 2))  # Exponential backoff
        fi
    done

    # If we reached the max retries without success, print an error
    handle_error "Command '$command' failed after $max_retries attempts" 2
}

# EC2 Control Functions

ec2_control1() {
    local instance_id=$1
    log "Running EC2 Control 1: Check if EC2 instance has monitoring enabled"
    
    local monitoring_state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].Monitoring.State' --output text)
    
    if [ "$monitoring_state" == "enabled" ]; then
        log "EC2 instance $instance_id has monitoring enabled."
    else
        error "EC2 instance $instance_id does not have monitoring enabled."
    fi
}

ec2_control2() {
    local instance_id=$1
    local security_group=$2
    log "Running EC2 Control 2: Check if EC2 instance is in the specified security group"
    
    local sg_ids=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' --output text)
    
    if [[ "$sg_ids" =~ "$security_group" ]]; then
        log "EC2 instance $instance_id is in the specified security group $security_group."
    else
        error "EC2 instance $instance_id is NOT in the specified security group $security_group."
    fi
}

ec2_control3() {
    local instance_id=$1
    local instance_type=$2
    log "Running EC2 Control 3: Check if EC2 instance is using the specified instance type"
    
    local instance_type_current=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].InstanceType' --output text)
    
    if [ "$instance_type_current" == "$instance_type" ]; then
        log "EC2 instance $instance_id is using the specified instance type $instance_type."
    else
        error "EC2 instance $instance_id is NOT using the specified instance type $instance_type."
    fi
}

ec2_control4() {
    local instance_id=$1
    log "Running EC2 Control 4: Check if EC2 instance is using encrypted volumes"
    
    local volume_ids=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].BlockDeviceMappings[*].Ebs.VolumeId' --output text)
    
    for volume_id in $volume_ids; do
        local encryption_state=$(aws ec2 describe-volumes --volume-ids "$volume_id" --query 'Volumes[0].Encrypted' --output text)
        
        if [ "$encryption_state" == "true" ]; then
            log "Volume $volume_id attached to EC2 instance $instance_id is encrypted."
        else
            error "Volume $volume_id attached to EC2 instance $instance_id is NOT encrypted."
        fi
    done
}

ec2_control5() {
    local instance_id=$1
    log "Running EC2 Control 5: Ensure EC2 instance is part of an Auto Scaling Group"
    
    local asg_name=$(aws autoscaling describe-auto-scaling-instances --instance-ids "$instance_id" --query 'AutoScalingInstances[0].AutoScalingGroupName' --output text)
    
    if [ "$asg_name" != "None" ]; then
        log "EC2 instance $instance_id is part of Auto Scaling Group $asg_name."
    else
        error "EC2 instance $instance_id is NOT part of an Auto Scaling Group."
    fi
}

# Main execution
main() {
    echo "AWS EC2 Compliance Automation Tool"
    echo "======================================"
    
    echo "Select action to perform:"
    echo "1) Run individual control"
    echo "2) Audit all EC2 instances in the account/region"

    read -p "Enter choice (1-2): " choice

    case $choice in
        1)
            echo "Select control to run:"
            echo "1) Ensure EC2 instances have monitoring enabled."
            echo "2) Ensure EC2 instances are in a specific security group."
            echo "3) Ensure EC2 instances are using a specific instance type."
            echo "4) Ensure EC2 instances are using encrypted volumes."
            echo "5) Ensure EC2 instances are part of an Auto Scaling Group."
    
            read -p "Enter control number (1-5): " control_choice
            
            case $control_choice in
                1)
                    read -p "Enter EC2 Instance ID: " instance_id
                    ec2_control1 "$instance_id" ;;
                2)
                    read -p "Enter EC2 Instance ID: " instance_id
                    read -p "Enter Security Group ID: " security_group
                    ec2_control2 "$instance_id" "$security_group" ;;
                3)
                    read -p "Enter EC2 Instance ID: " instance_id
                    read -p "Enter Desired Instance Type: " instance_type
                    ec2_control3 "$instance_id" "$instance_type" ;;
                4)
                    read -p "Enter EC2 Instance ID: " instance_id
                    ec2_control4 "$instance_id" ;;
                5)
                    read -p "Enter EC2 Instance ID: " instance_id
                    ec2_control5 "$instance_id" ;;
                *)
                    error "Invalid control selection" ;;
            esac
            ;;
        2)
            echo "Audit for all EC2 instances will be added later."
            ;;
        *)
            error "Invalid selection. Please choose a valid option." ;;
    esac
}

# Execute main function
main

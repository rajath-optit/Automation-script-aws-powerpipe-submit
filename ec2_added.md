#ec2_control1: Ensure AMIs are encrypted


#ec2_control2: Ensure AMIs are not older than 90 days


#ec2_control3: EC2 AMIs should restrict public access


#ec2_control4: EC2 Client VPN endpoints should have client connection logging enabled

#ec2_control5: EBS default encryption should be enabled

#ec2_control6: Ensure EBS volumes attached to an EC2 instance are marked for deletion upon instance termination


#ec2_control7: EC2 instance detailed monitoring should be enabled

#ec2_control8: EC2 instance should have EBS optimization enabled

#ec2_control9: EC2 instances should have IAM profile attached


#ec2_control10: EC2 instances should be in a VPC
}

#ec2_control11: EC2 instances should not use key pairs in running state


#ec2_control12: EC2 instances high-level findings should not be there in Inspector scans

#ec2_control13: EC2 instance IAM should not allow pass role and lambda invoke function access

#ec2_control14: EC2 instance IAM role should not be attached with credentials exposure access

#ec2_control15: EC2 instance IAM role should not allow altering critical S3 permissions 

#ec2_control16: EC2 instance IAM role should not allow cloud log tampering access

#ec2_control17: EC2 instance IAM role should not allow data destruction access


#ec2_control18: EC2 instance IAM role should not allow database management write access

#ec2_control19: EC2 instance IAM role should not allow defense evasion impact of AWS security 
#ec2_control20: EC2 instance IAM role should not allow destruction KMS access

#ec2_control21: EC2 instance IAM role should not allow destruction RDS access

#ec2_control22: EC2 instance IAM role should not allow elastic IP hijacking access

#ec2_control23: EC2 instance IAM role should not allow management-level access


#ec2_control24: EC2 instance IAM role should not allow new group creation with attached policy access


#ec2_control25: EC2 instance IAM role should not allow new role creation with attached policy access

#ec2_control26: EC2 instance IAM role should not allow new user creation with attached policy access


#ec2_control27: EC2 instance IAM role should not allow organization write access

#ec2_control28: EC2 instance IAM role should not allow privilege escalation risk access

#ec2_control29: EC2 instance IAM role should not allow security group write access


#ec2_control30: EC2 instance IAM role should not allow write access to resource-based policies


#ec2_control31: EC2 instance IAM role should not allow write permission on critical S3 configuration

#ec2_control32: EC2 instance IAM role should not allow write-level access

#ec2_control33: EC2 instances should not be attached to 'launch wizard' security groups

#ec2_control34: Ensure no AWS EC2 Instances are older than 180 days


#ec2_control35: EC2 instances should not have a public IP address


#ec2_control36: EC2 instances should not use multiple ENIs

#ec2_control37: EC2 instances should be protected by backup plan

#ec2_control38: Public EC2 instances should have IAM profile attached


#ec2_control39: AWS EC2 instances should have termination protection enabled

#ec2_control40: EC2 instances user data should not have secrets


#ec2_control41: EC2 instances should use IMDSv2


#ec2_control42: Paravirtual EC2 instance types should not be used

#ec2_control43: AWS EC2 launch templates should not assign public IPs to network interfaces

#ec2_control44: Ensure unused ENIs are removed


ec2_control45: EC2 stopped instances should be removed in 30 days

#ec2_control46: Ensure instances stopped for over 90 days are removed

#ec2_control47: EC2 transit gateways should have auto accept shared attachments disabled
ec2_control47() {
    log "Running EC2 Control 47: EC2 transit gateways should have auto accept shared attachments disabled"
    
    # Loop through all transit gateways
    for tgw_id in $(aws ec2 describe-transit-gateways --query 'TransitGateways[*].TransitGatewayId' --output text); do
        local auto_accept=$(aws ec2 describe-transit-gateway-attachments --transit-gateway-id "$tgw_id" --query 'TransitGatewayAttachments[*].AutoAccept' --output text)
        
        if [ "$auto_accept" == "true" ]; then
            error "EC2 transit gateway $tgw_id has auto accept shared attachments enabled"
        else
            log "EC2 transit gateway $tgw_id has auto accept shared attachments disabled"
        fi
    done
}

#ec2_control48: AWS EC2 instances should have termination protection enabled

#ec2_control50: EBS default encryption should be enabled
ec2_control50() {
    log "Running EC2 Control 50: EBS default encryption should be enabled"
    
    # Check if EBS default encryption is enabled in the region
    local ebs_encryption_enabled=$(aws ec2 describe-volumes --query 'Volumes[0].Encrypted' --output text)
    
    if [ "$ebs_encryption_enabled" != "True" ]; then
        error "EBS default encryption is not enabled"
    else
        log "EBS default encryption is enabled"
    fi
}

#ec2_control51: EC2 AMIs should restrict public access


#ec2_control52: EC2 instance detailed monitoring should be enabled


#ec2_control53: EC2 instance IAM role should not allow cloud log tampering access

#ec2_control54: EC2 instance IAM role should not allow data destruction access


#ec2_control55: EC2 instance IAM role should not allow database management write access

#ec2_control56: EC2 instance IAM role should not allow defense evasion impact of AWS security services access


#ec2_control57: EC2 instance IAM role should not allow destruction KMS access


#ec2_control58: EC2 instance IAM role should not allow destruction RDS access


#ec2_control59: EC2 instance IAM role should not allow elastic IP hijacking access


#ec2_control60: EC2 instance IAM role should not allow management level access


#ec2_control61: EC2 instance IAM role should not allow new group creation with attached policy access


#ec2_control62: EC2 instance IAM role should not allow new role creation with attached policy access


#ec2_control63: EC2 instance IAM role should not allow new user creation with attached policy access


#ec2_control64: EC2 instance IAM role should not allow organization write access


#ec2_control65:EC2 instance IAM role should not allow privilege escalation risk access"


#ec2_control66:EC2 instance IAM role should not allow security group write access"

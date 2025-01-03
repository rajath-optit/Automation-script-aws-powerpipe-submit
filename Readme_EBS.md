# AWS Compliance Automation Tool
## Overview
This automation tool helps bring AWS EBS and EC2 resources into compliance with best practices. The tool provides an interactive interface to select and apply various compliance controls to your AWS resources.

## Prerequisites
- AWS CLI installed and configured with appropriate permissions
- Bash shell environment
- jq utility (for JSON parsing)

## Installation
1. Clone the repository:
```bash
git clone https://github.com/your-repo/aws-compliance-automation.git
cd aws-compliance-automation
```

2. Make the script executable:
```bash
chmod +x aws_compliance.sh
```

## Usage
1. Run the script:
```bash
./aws_compliance.sh
```

2. Follow the interactive prompts:
   - Select resource type (EBS or EC2)
   - Enter resource ID
   - Choose specific control to apply

## Current Controls

### EBS Controls
1. **Delete on Termination**
   - Ensures EBS volumes are set to delete when the attached EC2 instance is terminated
   - Automatically modifies volume attributes
   - Provides detailed logging of changes

2. **Volume Encryption**
   - Checks if volumes are encrypted
   - Creates encrypted copies of unencrypted volumes
   - Manages the transition process automatically

### Control Details
#### EBS Control 1: Delete on Termination
- Checks current deletion settings
- Modifies settings if needed
- Verifies attachment status
- Reports success or failure

#### EBS Control 2: Volume Encryption
- Verifies current encryption status
- Creates encrypted snapshots
- Generates new encrypted volumes
- Manages the transition process

## Output
The script provides detailed output with:
- Timestamp for each action
- Color-coded status messages
- Success/failure notifications
- Resource IDs and states

## Error Handling
- Validates resource IDs
- Checks resource availability
- Provides clear error messages
- Includes recovery suggestions

## Best Practices
1. Always review changes before applying
2. Run in test environment first
3. Maintain backup snapshots
4. Monitor AWS CloudTrail logs

## Coming Soon
- EC2 compliance controls
- Additional EBS controls
- Batch processing capabilities
- Automated reporting

## Support
For issues or questions:
1. Check AWS documentation
2. Review CloudWatch logs
3. Contact AWS support if needed

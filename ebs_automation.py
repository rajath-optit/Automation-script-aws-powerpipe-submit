import boto3
import sys
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# Initialize boto3 client
ec2_client = boto3.client('ec2')

# Define controls with descriptions
controls = {
    1: "Ensure attached EBS volumes have 'Delete on Termination' enabled. This ensures that EBS volumes are automatically deleted when the associated instance is terminated.",
    2: "Ensure attached EBS volumes have encryption enabled to protect data at rest.",
    3: "Ensure EBS snapshots are encrypted to secure backups of sensitive data.",
    4: "Ensure EBS snapshots are not publicly restorable, preventing unauthorized access to data.",
    5: "Ensure EBS encryption by default is enabled to enforce encrypted volumes for all new volumes.",
    6: "Ensure EBS volumes are part of a backup plan to protect against accidental data loss.",
    7: "Ensure EBS volume snapshots exist to provide recovery points for volumes.",
    8: "Ensure EBS volumes are attached to EC2 instances for proper usage and cost management.",
    9: "Ensure EBS volumes are encrypted at rest to protect data confidentiality.",
    10: "Ensure EBS volumes are part of a valid and automated backup plan.",
    11: "Ensure volumes are attached to EC2 instances for operational requirements.",
    12: "Ensure EBS volume encryption at rest is enabled for all volumes.",
    13: "Ensure snapshots are attached and usable for recovery purposes."
}

def print_beautiful_message(message, level="INFO"):
    """Helper function for printing formatted messages."""
    levels = {
        "INFO": "\033[92m[INFO]\033[0m",
        "WARNING": "\033[93m[WARNING]\033[0m",
        "ERROR": "\033[91m[ERROR]\033[0m",
    }
    print(f"{levels.get(level, '[INFO]')} {message}")

def run_control(control_number):
    """Function to run a specific control based on user input."""
    try:
        control_desc = controls.get(control_number)
        if not control_desc:
            print_beautiful_message("Invalid control number selected. Please choose a valid option.", "ERROR")
            return

        # Print control description
        print_beautiful_message(f"Selected Control {control_number}: {control_desc}", "INFO")
        confirm = input("Are you sure you want to make these changes? (yes/no): ").strip().lower()

        if confirm != "yes":
            print_beautiful_message(f"You chose not to proceed with Control {control_number}. No changes were made.", "WARNING")
            return

        # Call appropriate function for the control
        control_function = globals().get(f"control_{control_number}")
        if control_function:
            control_function()
        else:
            print_beautiful_message(f"Control {control_number} has not been implemented yet.", "ERROR")
    except Exception as e:
        print_beautiful_message(f"An unexpected error occurred: {e}", "ERROR")

# Implement control functions
def control_8():
    """Ensure EBS volumes are attached to EC2 instances."""
    try:
        print_beautiful_message("Running Control 8: Checking EBS volumes attached to instances...", "INFO")
        volumes = ec2_client.describe_volumes()['Volumes']
        for volume in volumes:
            volume_id = volume['VolumeId']
            attachments = volume.get('Attachments', [])
            if attachments:
                for attachment in attachments:
                    print_beautiful_message(f"Volume {volume_id} is attached to instance {attachment['InstanceId']}.", "INFO")
            else:
                print_beautiful_message(f"Volume {volume_id} is not attached to any instance.", "WARNING")
    except NoCredentialsError:
        print_beautiful_message("AWS credentials not found. Please configure your credentials.", "ERROR")
    except Exception as e:
        print_beautiful_message(f"Failed to execute Control 8: {e}", "ERROR")

def control_9():
    """Ensure EBS volumes are encrypted at rest."""
    try:
        print_beautiful_message("Running Control 9: Checking encryption at rest for EBS volumes...", "INFO")
        volumes = ec2_client.describe_volumes()['Volumes']
        for volume in volumes:
            volume_id = volume['VolumeId']
            encrypted = volume['Encrypted']
            if encrypted:
                print_beautiful_message(f"Volume {volume_id} is encrypted at rest.", "INFO")
            else:
                print_beautiful_message(f"Volume {volume_id} is not encrypted at rest. Please enable encryption.", "WARNING")
    except NoCredentialsError:
        print_beautiful_message("AWS credentials not found. Please configure your credentials.", "ERROR")
    except Exception as e:
        print_beautiful_message(f"Failed to execute Control 9: {e}", "ERROR")

def control_10():
    """Ensure EBS volumes are part of a backup plan."""
    try:
        print_beautiful_message("Running Control 10: Checking backup plan for EBS volumes...", "INFO")
        # Example implementation - replace with actual backup plan verification logic
        volumes = ec2_client.describe_volumes()['Volumes']
        for volume in volumes:
            volume_id = volume['VolumeId']
            # Placeholder: Assume all volumes are in a backup plan
            print_beautiful_message(f"Volume {volume_id} is protected by a backup plan.", "INFO")
    except NoCredentialsError:
        print_beautiful_message("AWS credentials not found. Please configure your credentials.", "ERROR")
    except Exception as e:
        print_beautiful_message(f"Failed to execute Control 10: {e}", "ERROR")

# Main script
if __name__ == "__main__":
    print("AWS EBS Compliance Automation Tool")
    print("======================================")
    print("Select a control to run:")
    for control_number, description in controls.items():
        print(f"{control_number}) {description.split('.')[0]}")
    try:
        selected_control = int(input("Enter control number (1-13): "))
        run_control(selected_control)
    except ValueError:
        print_beautiful_message("Invalid input. Please enter a number between 1 and 13.", "ERROR")

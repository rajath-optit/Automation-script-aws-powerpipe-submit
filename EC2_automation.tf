#!/bin/bash
function Control1
{
ec2-control1.tf


}
function Control2
{
ec2-control2.tf

trrraform init
terraform plan
terraform apply
}

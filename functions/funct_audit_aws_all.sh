# funct_audit_aws_all
#
# Audit AWS
#
# Run various AWS audit tests
# 
# This requires the AWS CLI to be installed and configured
#.

funct_audit_aws_all () {
	audit_aws_iam
  audit_aws_mfa
  audit_aws_access_keys
  audit_aws_creds
  audit_aws_iam_policies
  audit_aws_support_role
}
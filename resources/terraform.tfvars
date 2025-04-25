vpc_name        = "ghostcms-vpc"
region = "ap-south-1"
# nat_gateway_name="trezix-nat-gateway-ap-south-1"
# cluster_version="1.32"
eks_cluster_name = "ghostcms-eks"
vpc_cidr = "172.22.0.0/16"
private_subnet_cidr_1="172.22.4.0/22"
private_subnet_cidr_2="172.22.12.0/22"
public_subnet_cidr_1="172.22.0.0/22"
public_subnet_cidr_2="172.22.8.0/22"
nat_gateway_name="ghostcms-nat"
db_private_subnet_cidr_1    = "172.22.64.0/20"
db_private_subnet_cidr_2="172.22.80.0/20"

# # vpn_vpc

# vpn_vpc_name        = "tz-vpn-vpc"
# # region = "ap-south-1"
# # nat_gateway_name="trezix-nat-gateway-ap-south-1"
# # cluster_version="1.32"
# # eks_cluster_name = "trezix-dev-eks_cluster"
# vpn_vpc_cidr = "172.23.0.0/16"
# vpn_private_subnet_cidr_1="172.23.128.0/20"
# vpn_private_subnet_cidr_2="172.23.144.0/20"
# vpn_public_subnet_cidr_1="172.23.0.0/20"
# vpn_public_subnet_cidr_2="172.23.16.0/20"
# # vpn_nat_gateway_name="tz-jenkins-nat"172.23.16.0/20


# # monit-vpc
# monit_vpc_name        = "tz-monitoring-vpc"
# monit_nat_gateway_name="trezix-monitoring-nat-gateway"
# monit_cluster_version="1.32"
# monit_eks_cluster_name = "trezix-monitoring-eks"
# monit_vpc_cidr = "172.25.0.0/16"
# monit_private_subnet_cidr_1="172.25.128.0/20"
# monit_private_subnet_cidr_2="172.25.144.0/20"
# monit_public_subnet_cidr_1="172.25.0.0/20"
# monit_public_subnet_cidr_2="172.25.16.0/20"
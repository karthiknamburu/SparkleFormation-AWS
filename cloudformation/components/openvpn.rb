SparkleFormation.build do
  set!('AWSTemplateFormatVersion', '2010-09-09')

  description 'prepare an instance using the OpenVpn ami already created, subnet, and security group'

  parameters do
    key_name do
      type 'String'
      description 'Name of and existing EC2 KeyPair to enable SSH access to SIMS instances'
      default 'sims-admin'
    end

    openvpn_ami_id do
      type 'String'
      description 'OpenVPN AMI You want to use'
      default 'ami-c8b9f3a2'
    end

    instance_type do
      type 'String'
      allowed_values %w( m1.small m1.large )
      default 'm1.large'
    end
  end

  # resource IDs we need from the VPC layer
  %w( vpc_id public_subnet ).each do |r|
    parameters(r.to_sym) do
      type 'String'
    end
  end

  resources(:instance_security_group) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      vpc_id ref!(:vpc_id)
      group_description 'allow access to ec2 instance'
      security_group_ingress _array(
        -> {
          ip_protocol 'tcp'
          from_port 22
          to_port 22
          cidr_ip '0.0.0.0/0'
        }
        -> {
          ip_protocol 'TCP'
          from_port 943
          to_port 943
          cidr_ip '0.0.0.0/0'
        }
        -> {
          ip_protocol 'UDP'
          from_port 1194
          to_port 1194
          cidr_ip '0.0.0.0/0'
        }
         -> {
          ip_protocol 'TCP'
          from_port 443
          to_port 443
          cidr_ip '0.0.0.0/0'
        }
      )
    end
  end

  resources(:ec2_instance) do
    type 'AWS::EC2::Instance'
    properties do
      instance_type ref!(:instance_type)
      image_id ref!(:open_vpn_ami_id)
      security_group_ids [ref!(:instance_security_group)]
      subnet_id ref!(:public_subnet)
      key_name ref!(:key_name)
    end
  end

  resources(:instance_elastic_ip) do
    type 'AWS::EC2::EIP'
    properties do
      domain 'vpc'
      instance_id ref!(:ec2_instance)
    end
  end

  outputs do
    instance_id do
      description 'Instance Id of newly created instance'
      value ref!(:ec2_instance)
    end

    instance_ip do
      description 'Public IP address of newly created instance'
      value ref!(:instance_elastic_ip)
    end
  end

end

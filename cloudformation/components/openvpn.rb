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
      allowed_values %w( t2.small t2.large )
      default 't2.large'
    end
  end

end

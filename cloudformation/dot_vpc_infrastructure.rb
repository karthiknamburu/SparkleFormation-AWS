SparkleFormation.new(:dev_sims_SF).load(:openvpn,:vpc).overrides do
  
  parameters(:public_subnet_availability_zone) do
    type 'String'
    default 'us-east-1a'
  end

  parameters(:private_subnet_availability_zone) do
    type 'String'
    default 'us-east-1c'
  end

  dynamic!(:subnet, 'public',
      :vpc_id => ref!(:vpc),
      :route_table => ref!(:public_route_table),
      :availability_zone => ref!(:public_subnet_availability_zone)
  )

  dynamic!(:subnet, 'private',
      :vpc_id => ref!(:vpc),
      :route_table => ref!(:private_route_table),
      :availability_zone => ref!(:private_subnet_availability_zone)
  )



  # # resource IDs we need from the VPC layer
  # %w( vpc_id public_subnet ).each do |r|
  #   parameters(r.to_sym) do
  #     type 'String'
  #   end
  # end

  resources(:instance_security_group) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      vpc_id ref!(:vpc)
      group_description 'allow access to ec2 instance'
      security_group_ingress _array(
        -> {
          ip_protocol 'tcp'
          from_port 22
          to_port 22
          cidr_ip '0.0.0.0/0'
        }
      )
    end
  end

  resources(:ec2_instance) do
    type 'AWS::EC2::Instance'
    properties do
      instance_type ref!(:instance_type)
      image_id ref!(:openvpn_ami_id)
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
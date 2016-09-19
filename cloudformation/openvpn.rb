SparkleFormation.new(:open_vpn).load(:openvpn).overrides do
  
  parameters(:public_subnet_availability_zone) do
    type 'String'
    default 'us-east-1a'
  end

  parameters(:private_subnet_availability_zone) do
    type 'String'
    default 'us-east-1c'
  end

##Create private and public subnets
  dynamic!(:subnet, 'public',
      :vpc_id => ref!(:vpc),
      :route_table => ref!(:public_route_table),
      :availability_zone => ref!(:public_subnet_availability_zone)
  )

  dynamic!(:subnet, 'private',
      :vpc_id => ref!(:vpc),
      #:route_table => ref!(:private_route_table),
      :availability_zone => ref!(:private_subnet_availability_zone)
  )

##Create Security groups for the resource being used in AWS.

#Create a Public Security Group
  resources(:public_instance_security_group) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      vpc_id ref!(:vpc)
      group_description 'Setup Web server and users access security rules'
       tags _array(
        -> {
          Key 'Name'
          Value 'public-dot-sims'
        }
      )
    end
  end

  resources(:http_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:public_instance_security_group)
        ip_protocol 'tcp'
        from_port 80
        to_port 80
        cidr_ip '0.0.0.0/0'
      end
  end

   resources(:https_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:public_instance_security_group)
        ip_protocol 'tcp'
        from_port 443
        to_port 443
        cidr_ip '0.0.0.0/0'
      end
    end


#Create a Private Security Group
  resources(:private_instance_security_group) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      vpc_id ref!(:vpc)
      group_description 'allow access to public instances'
       tags _array(
        -> {
          Key 'Name'
          Value 'dot-sims-Private'
        }
      )
    end
  end

  resources(:postgres_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:private_instance_security_group)
        ip_protocol 'tcp'
        from_port 5432
        to_port 5432
        cidr_ip ref!(:public_subnet_cidr)
      end
  end

   resources(:memcache_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:private_instance_security_group)
        ip_protocol 'tcp'
        from_port 11211
        to_port 11211
        cidr_ip ref!(:public_subnet_cidr)
      end
    end

#Create OpenVpn security Group
  resources(:openvpn_instance_security_group) do
    type 'AWS::EC2::SecurityGroup'
    properties do
      vpc_id ref!(:vpc)
      group_description 'allow access to ec2 instance'
       tags _array(
        -> {
          Key 'Name'
          Value 'OpenVpn'
        }
      )
    end
  end

  resources(:ssh_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:openvpn_instance_security_group)
        ip_protocol 'tcp'
        from_port 22
        to_port 22
        cidr_ip '0.0.0.0/0'
      end
  end

   resources(:https_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:openvpn_instance_security_group)
        ip_protocol 'tcp'
        from_port 443
        to_port 443
        cidr_ip '0.0.0.0/0'
      end
    end

    resources(:tcp_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:openvpn_instance_security_group)
        ip_protocol 'tcp'
        from_port 943
        to_port 943
        cidr_ip '0.0.0.0/0'
      end
    end

    resources(:udp_security_group_ingress) do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:openvpn_instance_security_group)
        ip_protocol 'udp'
        from_port 1194
        to_port 1194
        cidr_ip '0.0.0.0/0'
      end
    end

##Create a RDS DB Security Group
# resources(:rds_db_security) do
#  type 'AWS::RDS::DBSecurityGroup'
#  properties do
#   EC2VpcId ref!(:vpc)
#   group_description 'Select the VPC for RDS'
#   tags _array(
#         -> {
#           Key 'Name'
#           Value 'prod-db-sims'
#         }
#   )
#   DBSecurityGroupIngress _array(
#         -> {
#         #group_description 'DB security'  
#         #EC2SecurityGroupId get_att!(:private_instance_security_group,group_id)
#         # EC2SecurityGroupId '647367351522'
#          EC2SecurityGroupName ref!(:private_instance_security_group)
#         #EC2SecurityGroupId ref!(:vpc)
#         } 
#   )
#   end
# end

# ##Create RDS subnet 
# resources(:rds_db_subnet)
#  type 'AWS::RDS::DBSubnetGroup'
# properties do
#   DBSubnetGroupDescription 'SIMS Subnet group'
#   SubnetIds ref!()
# end

# resources(:rds_security_group_ingress) do
#   type 'AWS::RDS::DBSecurityGroupIngress'
#     properties do
#         DBSecurityGroupName ref!(:rds_db_security) 
#         EC2SecurityGroupName ref!(:private_instance_security_group)
#         EC2SecurityGroupOwnerId '647367351522'
#      end
#  end



##Create a ElastiCache(memcache) instance




##Create a RDS instance in Private Subnet
  # resources(:rds) do
  #   type 'AWS::RDS::DBInstance'

  #   properties do
  #     DBInstanceIdentifier (:DBInstanceIdentifier)
  #     DB_Security_Groups [ref!(:rds_db_security)]
  #     Engine ref!(:Engine)
  #     Engine_Version ref!(:EngineVersion)
  #     DBInstanceClass ref!(:DBInstanceClass)
  #     MultiAZ ref!(:MultiAZ)
  #     DBName ref!(:DBName)
  #     Port ref!(:Port)
  #     set!('DBName'._no_hump, ref!(:DBName))
  #     set!('MultiAZ'._no_hump, true)
  #     #set!('DBInstanceClass'._no_hump, :DBInstanceClass)
  #     #subnet_id ref!(:private_subnet)
  #     Allocated_Storage ref!(:AllocatedStorage)
  #     Master_Username ref!(:MasterUsername)
  #     Master_User_Password ref!(:MasterUserPassword)
  #   end

  # end

##Create a EC2 Instance with OpenVpn server.

  #Create instance using the registedred AMI.
  resources(:ec2_instance) do
    type 'AWS::EC2::Instance'
    properties do
      instance_type ref!(:instance_type)
      image_id ref!(:openvpn_ami_id)
      security_group_ids [ref!(:openvpn_instance_security_group)]
      subnet_id ref!(:public_subnet)
      key_name ref!(:key_name)
       tags _array(
        -> {
          Key 'Name'
          Value 'OpenVpn-prod'
        }
      )
    end
  end

 # Assign a elastic IP for the instance.
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
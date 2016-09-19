
SparkleFormation.build do
  parameters(:Engine ) do
    description 'SIMS DB Engine'
    type 'String'
    default 'postgres'
  end

  parameters(:EngineVersion) do
    description 'DB Engine Version'
    type 'String'
    default '9.4.4'
  end

  parameters(:DBInstanceIdentifier) do
    description 'DB Identifier'
    type 'String'
    default 'sims-prod'
  end

   parameters(:DBInstanceClass) do
    description 'Select Instance type'
    type 'String'
    allowed_values %w( db.m3.large db.m3.xlarge )
    default 'db.m3.large'
  end

  parameters(:MultiAZ) do
    description 'Enable MultiAZ'
    type 'String'
    default 'true'
    allowed_values %w(true false)
  end

  parameters(:DBName) do
    description 'SIMS DB Name'
    type 'String'
    default 'sims'
  end

  parameters(:MasterUsername) do
    description 'SIMS DB User Name'
    type 'String'
    default 'app'
  end

  parameters(:MasterUserPassword) do
    description 'SIMS DB Password'
    type 'String'
    default 'dotsims2015'
  end

  parameters(:AllocatedStorage) do
    description 'Storage Allocation'
    type 'String'
    default '100'
  end

  parameters(:Port) do
    description 'port'
    type 'String'
    default '5432'
  end

  # parameters(:DBSecurityGroupName) do
  #   description 'DBSecurityGroupName'
  #   type 'String'
  #   default '5432'
  # end

  # resources(:DBSubnetGroup) do
  #   type 'AWS::RDS::DBSubnetGroup'
  #   properties do

  #     DBSubnetGroupDescription ''
  #   end
  # end

  # "DBInstanceIdentifier"  : "test-db",
  #  "Engine"                : "sqlserver-ex",
  #               "Port"                  : "1433",
  #               "DBInstanceClass"       : "db.t1.micro",
  #               "AllocatedStorage"      : "30",
  #               "MasterUsername"        : "sa",
  #               "MasterUserPassword"    : "password"

end
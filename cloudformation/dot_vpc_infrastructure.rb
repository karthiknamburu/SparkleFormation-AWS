SparkleFormation.new(:dev_sims_SF).load(:vpc).overrides do
  
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

end
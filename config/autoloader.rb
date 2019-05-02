require BASE_PATH + '/app/base.rb'
%w{/app/models /app/helpers /app/routes /lib /app/constants /app/services}.each do |dir|
  resource_dir = BASE_PATH + dir

  Dir[File.join(resource_dir, '**/*.rb')].each do |file|
    require file
  end
end

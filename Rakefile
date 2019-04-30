require_relative 'config/boot'
require_relative 'sinatra_concierge_app'

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    db = Sequel.connect(YAML.load_file("#{SinatraConciergeApp::ROOT}/config/database.yml")[ENV['RACK_ENV']])
    migration_path = "#{SinatraConciergeApp::ROOT}/db/migrations"

    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, migration_path, target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, migration_path)
    end
  end
end

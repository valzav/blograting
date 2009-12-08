task :default do
  sh "rake -T"
end

namespace :db do

  namespace :migrate do
    desc 'Resets the database through scripts in db/ (all data will be lost)'
    task :reset => [:sequel_migrations, :sinatra] do
      puts "migrated to version %d" % Sequel::Migrator.apply(DB, 'db/',0)
      puts "migrated to version %d" % Sequel::Migrator.apply(DB, 'db/')
    end
  end

  desc 'Migrate the database through scripts in db/'
  task :migrate => [:sequel_migrations, :sinatra] do
    current_version = Sequel::Migrator.get_current_migration_version(DB)
    puts "migrated to version %d from version %d" % [Sequel::Migrator.apply(DB, 'db/'), current_version]
  end
  
  desc 'Populate db with seed data'
  task :seed => [:sinatra] do
    require 'db/seeds.rb'
  end

  desc 'Creates database for the current environment (or maybe for all - dev, production, test?)'
  task :create => [:sequel] do
    #TODO: implement
  end
end

task :sinatra do
  require 'app.rb'
end

task :sequel do
  require 'sequel'
end

task :sequel_migrations do
  require 'sequel/extensions/migration.rb'
end

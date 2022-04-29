namespace :db do
  desc 'init'
  task :init do
    puts 'DROP ALL DATABASES'
    Rake::Task['db:drop'].invoke
    Rake::Task['parallel:drop'].invoke
    puts 'CREATE ALL DATABASES'
    Rake::Task['db:create'].invoke
    Rake::Task['parallel:create'].invoke
    puts 'MIGRATE ALL DATABASES'
    Rake::Task['db:migrate'].invoke
    Rake::Task['parallel:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end
end

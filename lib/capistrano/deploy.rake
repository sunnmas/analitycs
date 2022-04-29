namespace :deploy do
  task :ssh_add do
    on roles :all do
      execute 'ssh-add ~/.ssh/id_rsa'
    end
  end

  task :sudo do
    on roles :all do
      sudo 'lsb_release -a'
      sudo 'free -m -h'
    end
  end

  task :sudo_cleanup do
    on roles :all do
      count = fetch(:keep_releases).to_i
      sudo "ls -1dt #{releases_path}/* | tail -n +#{count + 1} | sudo xargs rm -rf"
    end
  end

  after :updated, :sudo_cleanup
end

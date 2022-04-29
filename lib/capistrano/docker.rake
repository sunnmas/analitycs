namespace :docker do
  task :build do
    on roles :all do
      # rails_image_version = "#{capture("cat #{fetch(:deploy_to)}/current/REVISION")}"
      execute :docker, "build #{fetch(:deploy_to)}/current/config/docker/rails/DockerFile --label analitycs"
    end
  end
end

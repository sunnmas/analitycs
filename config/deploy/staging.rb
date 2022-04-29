stage_ip = 'k8s-master'
puts "stage server ip: #{stage_ip}"
server stage_ip, user: 'deployer', roles: %w{web app}

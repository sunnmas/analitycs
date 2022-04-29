puts 'RUN SEEDS'.yellow
ActiveRecord::Base.connection.reset_pk_sequence!('users')

def check_creation(objects)
  objects.each do |object|
    unless object.valid?
      puts "#{object.class.name} creation failed:".red
      puts object.inspect
      puts "#{object.class.name} errors:".red
      puts object.errors.messages
      exit
    end
  end
  models = objects.first.class.name
  print models
  (1..50-models.length).each {|i| print '.'}
  puts 'OK'.green

end
admin = User.create email: '89520765032@yandex.ru', password: 'admin-password-415'

check_creation [admin]
puts "OK. All the seeds are planted!".green

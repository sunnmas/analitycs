## Запуск проекта в development mode
-1. В системе ruby2.7, redis5.0, postgres12.9, +(rubymine, pgadmin)
0. Качаем исходники
1. bundle install
2. Получаем ключи development.key и test.key
3. Ложим ключи в app/config/credentials
4. EDITOR="nano" rails credentials:edit --environment development - редактируем файл секретов
5. sudo -u postgres psql --command="CREATE ROLE \"analytics.usr\" LOGIN PASSWORD '!!!!!password_dev_credential!!!!!' NOSUPERUSER NOINHERIT CREATEDB NOCREATEROLE NOREPLICATION;"
6. rails db:init
7. RAILS_ENV=development foreman start -f Procfile - запуск проекта с джобами
8. Логинимся 127.0.0.1:3000 пароль берем из файла seed
9. rails parallel:test - прогон тестов в параллельном режиме
   rails test          - прогон тестов в последовательном режиме

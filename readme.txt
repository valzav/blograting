Рейтинг блогов на ruby/sinatra на основе Yandex API, см. http://blogs.yandex.ru/faq/entriesapi


Зависимости.

Gems: rack, sinatra, compass, haml, sequel, rutils, curb, nokogiri, rack-test, cucumber


Установка.

# создаем базы данных в mysql
mysql -u root -e "create database blogovod_dev; create database blogovod_prod"

# мигрируем бд на последнюю схему
rake db:migrate:reset

# загружаем в бд начальные данные
rake db:seed

# запускаем процесс сбора данных
ruby lib/feeder start

# запускаем sinatra
script/server

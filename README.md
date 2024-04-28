# README

This application is a similation of Queen's Blood inside Square Enix's RPG game, Final Fantasy VII Rebirth (2024).  The intention of this project is entirely for fan entertainment as we are so addicted to the card game.  We do not own any rights to the game, the characters, or the assets.  If you are part of Square Enix's copyright team that needs to discuss some things, you can contact us.

* Technologies
* Configuration
* Database
* Deployment

# Technologies
It's developed in Ruby on Rails platform based in Unix/Linux operating system.  You can try on other RoR compatible systems.
* Ruby version: 3.3 tested
* Rails version: 7.1
* JQuery: 3.7
* JQuery-UI: 1.13

# Configuration
* Before running database migrations, ensure your database server has the necessary database/repository according to running Rails environment, and authentication.
* Within your specified environment, run `bin/rails db:migrate` to setup database schemas and data.  Run `bin/rails db:seed` to populate initial data.

# Database
* Development environment for now uses sqlite3 instead of MySQL: inside folder db/development.sqlite3
* Test environment for now uses sqlite3 instead of MySQL: inside folder db/test.sqlite3
* Production environment is set to run with MySQL based database.

# Deployment
* Run the puma Rails server: bin/rails s
* If using the MySQL database, ensure that's running.
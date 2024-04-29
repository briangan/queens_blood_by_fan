# README

This application is a similation of Queen's Blood inside Square Enix's RPG game, Final Fantasy VII Rebirth (2024).  The intention of this project is entirely for fan entertainment as we are so addicted to the card game.  We do not own any rights to the game, the characters, or the assets.  If you are part of Square Enix's copyright team that needs to discuss some things, you can contact us.

* Technologies
* Resources
* Configuration
* Database
* Deployment
* Contributions

# Technologies
It's developed in Ruby on Rails platform based in Unix/Linux operating system.  You can try on other RoR compatible systems.
* Ruby version: 3.3 tested
* Rails version: 7.1
* JQuery: 3.7
* JQuery-UI: 1.13

# Resources
* Graphics
  - Card images downloaded from 

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

# Contributions
Currently this is a publicly free to access source code repository, so you are free to download or clone the codes.  It'd best if you are willing to participate by programming or preparing other parts of the project.  So you are welcomed to help out.
Here are the upcoming TODOs:
* Crop out card bare images
  - Inside folder public/cards there are downloaded images of 145 cards from .  But each card image includes the explanation of card behaviors (which is great for data) on the right side.  
  - I created a Photoshop file that has another layer with shape of only bare card without any BG, text or graphics.  So editor can load the selection by using the card shape, and copy image content only within the selection; open new image pasted with the bare card graphics, turn off background to keep cornders transparent and export as PNG file.
* Write out data, abilities and affected of each card into data/cards.yml file.  Can refer to card images inside public/cards that have explanations exactly from the game.  The attributes are type, name, card_number, abilities, pawn_tiles, and affected_tiles.  Each ability has attributes type, description, when, which, and action.  Each pawn_tile or affected_tile should have joint x & y positions away from center of the card, either positive or negative, for example, "0,1" being on the same column (x tile horizontally) and 1 row above (y tile veritically).  Negative values means going either left or below direction.
* Ideal UI tool to set the affected_tiles of a card would be grid of tiles for selection, and output into raw data like JSON or save into database table.
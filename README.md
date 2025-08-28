# README

This application is a simulation of Queen's Blood inside Square Enix's RPG game, Final Fantasy VII Rebirth (2024).  The intention of this project is entirely for fan entertainment as we are so addicted to the card game what the company has not refactored out as public mobile game.  We do not own any rights to the game, the characters, or the assets.  If you are part of Square Enix's copyright team that needs to discuss some details, you can contact us.

* Technologies
* Resources
* Configuration
* Database
* Deployment
* Contributions
* TODOs

# Technologies
It's developed in Ruby on Rails platform based in Unix/Linux operating system.  You can try on other RoR compatible systems.
* Ruby: v3.3.8 tested
* Rails: v7.1
* JQuery: v3.7
* JQuery-UI: v1.13
* SQLite

# Resources
* Graphics
  - Card images downloaded from https://game8.co/games/Final-Fantasy-VII-Rebirth/archives/Queens-Blood

# Installation
Ensure /Gemfile has 
gem 'rails', '~> 7.2'
gem 'importmap-rails'
gem 'hotwire-rails'
gem 'turbo-rails'

Run bin/rails importmap:install then bin/rails hotwire:install then bin/rails turbo:install


# Configuration
* Before running database migrations, ensure your database server has the necessary database/repository according to running Rails environment, and authentication.
* Within your specified environment, run `bin/rails db:migrate` to setup database schemas and data.  Run `bin/rails db:seed` to populate initial data.

# Database
* Development environment for now uses sqlite3 instead of MySQL: inside folder db/development.sqlite3
* Test environment for now uses sqlite3 instead of MySQL: inside folder db/test.sqlite3
* Production environment is set to run with Postgresql based database.  

The settings inside config/database.yml
heroku config:set DATABASE_URL='NEON_DATABASE_CONNECTION_STRING' -a neon-heroku-example

# Deployment
* Run the puma Rails server: bin/rails s
* If using the MySQL database, ensure that's running.

## Heroku Usage for Hosting
* Staging site domain: https://boiling-beach-44284-60e062035d00.herokuapp.com/ 
* GIT: https://git.heroku.com/boiling-beach-44284.git

```
Steps to setup GIT w/ heroku:
install local heroku program; for example, Mac would run `brew install heroku`

Set necessary environment variables on heroku's site:


Then run:
heroku login
heroku create
heroku git:remote -a boiling-beach-44284
heroku buildpacks:add heroku/nodejs --index 1

git add heroku master
git remote add heroku https://git.heroku.com/boiling-beach-44284.git
git push heroku master

To run commands on heroku, such as initial `bin/rails db:migrate` and `bin/rails db:seed`
can start terminal w/
heroku run bash
```


# Contributions
Currently this is a publicly free to access source code repository, so you are free to download or clone the codes.  It'd best if you are willing to participate by programming or preparing other parts of the project.  So you are welcomed to help out by doing some TODOs or share new ideas.


# TODOs:
## Cards
* Implement "create another card after usage" cards 
  [ ] There r some "create another card after usage" cards such as Grangalan that can create Grangalan Junior.
  [ ] Different card image than its parent
  [ ] Use of AddCardAbility to add GameCard to associate child Card
* Browse, Search
  [x] turbo_stream reset search/empty keyword would not re-render the long list to all the cards => update instead of replace
  [ ] show card to non-manager more details: card tiles, abilities
  [ ] homepage
    [ ] added dynamic carousel

* Data entry of cards
  - Enter attributes, abilities and tiles of each card into data/cards.yml file.  This would be valid values into DB table.
  - Can refer to card images inside public/cards that have explanations exactly from the game.  
  - The attributes are type, name, category, card_number, description, pawn_rank, power, abilities, raise_pawn_rank, pawn_tiles, and affected_tiles.  
  - Each ability has attributes type, description, when, which, and action.  
  - Each pawn_tile or affected_tile should have array of x & y positions away from center of the card, either positive or negative, for example, "[0,1]" being on the same column (x tile horizontally) and 1 row above (y tile veritically).  Negative values means going either left or below direction.
  - Questionable behaviors of affective_tiles: do the affected tiles claim or raise pawn rank of each tile also?  For example, Card #83, all red affected tiles are dotted; yet for instance, Card #86 Cloud has all red affected tiles dotted except one being solid red.
  - Fetch data of added card when triggered, such as Card #94 Vincent.  Added card is not in numbered card list.  Thus, how to save the condition in data/DB to interpret adding or spawning which card.

## Game Play
* Initial Game
  [ ] Randomly out initial cards, and ask players to skip some

* Check next turn
  [ ] when not your turn, overlay cards wrapper w/ another layer
  [ ] option to pass
  [ ] both side passing to end game

* After create move
  [ ] check if 2 players have passed consecutively, then game over
  [ ] calculate total based on winning lanes; then who wins
  [ ] close up game

## Users
* User Control
  [x] added cancancan, added roles, key controller actions added w/ authorize_user

## User Interactions
* action streaming - broadcast
  [x] broadcast to the other player
  [ ] move broadcast to background job

## Game Play
* While watching opponent's making a move, disable any action by this player.
* Allow third person view only on existing game in play by other 2 players.

## Front End
* Playing Cards
  - Different CSS styles for player 1 and player 2
* Realtime replay of player actions using ActionCable.  Most basic action to track is placement of card.  Extra actions to track could include selection of card, or even segments of card's path.
* Board Tiles
  - Claimed tile would have different CSS based on player 1 or player 2
* Admins
  - Ideal UI tool to set the affected_tiles of a card would be grid of tiles for selection, and output into raw data like JSON or save into database table.

## Security
  [ ] analyize whether player can cheat w/ custom Javascript calls
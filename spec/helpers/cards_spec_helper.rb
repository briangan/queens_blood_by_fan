module CardsSpecHelper
  # Erases all existing cards and reloads them from the seeds file.
  # @return [Hash] Record counts of Card, card_tiles, and card_abilities.
  def reload_cards
    Board.all.each(&:destroy)
    Card.all.each(&:destroy)
    record_counts = {} # Class name => count
    File.open( Rails.root.join('db', 'seeds.rb'), 'r') do |f|
      f.each_line do |line|
        if (class_name = line.match(/([a-z_]+)\.create/i).try(:[], 1) ).present?
          record_counts[class_name] ||= 0
          record_counts[class_name] += 1
        end
      end
    end

    # Load all now
    load Rails.root.join('db', 'seeds.rb')

    expect(Card.count).to eq(record_counts['Card'])
    expect(CardTile.count).to eq(record_counts['card_tiles'])
    expect(CardAbility.count).to eq(record_counts['card_abilities'])
    expect(Board.count).to eq(record_counts['Board'])

    record_counts
  end

  def prepare_cards_and_decks_for_user(user)
    current_card_ids = UserCard.where(user_id: user.id).collect(&:card_id).uniq
    how_many_more = Deck::MAX_CARDS_PER_DECK + 5 + rand(10) - current_card_ids.size 
    Card.where.not(id: current_card_ids).limit(how_many_more).order('RANDOM()').each do |card|
      UserCard.create(user_id: user.id, card_id: card.id)
    end
    puts "Collected #{UserCard.where(user_id: user.id).count} cards for user #{user.username} (#{user.id})"
    expect(UserCard.where(user_id: user.id).count).to be >= Deck::MAX_CARDS_PER_DECK

    Deck.populate_decks_for_user(user)
    expect(Deck.where(user_id: user.id).count).to eq Deck::MAX_DECKS_PER_USER

    Deck.includes(:deck_cards).where(user_id: user.id).each do |deck|
      UserCard.where(user_id: user.id).where("card_id NOT IN (?)", deck.deck_cards.collect(&:card_id)).order('RANDOM()').limit(Deck::MAX_CARDS_PER_DECK - deck.deck_cards.size ).each do |user_card|
        DeckCard.create(deck_id: deck.id, card_id: user_card.card_id)
      end
      expect(deck.deck_cards.count).to be <= Deck::MAX_CARDS_PER_DECK
    end

  end
end
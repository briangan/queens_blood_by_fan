module CardsSpecHelper
  # Erases all existing cards and reloads them from the seeds file.
  # @return [Hash] Record counts of Card, card_tiles, and card_abilities.
  def reload_cards
    Card.__elasticsearch__.create_index!(force: true) if Elasticsearch.available?
    Board.all.each(&:destroy)
    Card.all.each do|c|
      begin
        c.destroy
      rescue Elastic::Transport::Transport::Error
      end
    end
    CardTile.all.each(&:destroy)
    CardAbility.all.each(&:destroy)
    record_counts = {} # Class name => count
    File.open( Rails.root.join('db', 'seeds.rb'), 'r') do |f|
      f.each_line do |line|
        if (class_name = line.match(/([a-z_]+)\.(find_or_)?create/i).try(:[], 1) ).present?
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

  def prepare_cards_and_decks_for_user(user, essential_card_numbers = nil)
    essential_card_ids = essential_card_numbers.present? ? Card.where(card_number: essential_card_numbers).select('id').all.collect(&:id) : []
    user.random_pick_cards(essential_card_ids)
    
    puts "Collected #{UserCard.where(user_id: user.id).count} cards for user #{user.username} (#{user.id})"
    expect(UserCard.where(user_id: user.id).count).to be >= Deck::MAX_CARDS_PER_DECK

    if essential_card_numbers.present?
      expect(user.cards.where(card_number: essential_card_numbers).count).to eq(essential_card_numbers.size), "User #{user.username} should have cards with numbers #{essential_card_numbers.join(', ')}"
    end

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
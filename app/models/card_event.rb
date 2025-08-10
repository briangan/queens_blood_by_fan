# @game <Game> the game instance here might be different from self.game when record changes are't saved.
# @card <Card> the card being played; if nil, would use current_card
# @card_event <String> 1 of these card in a tile event: 'played', 'destroyed', 'enhanced', 'enfeebled'
# @options <Hash> additional options for the event, such as :dry_run
CardEvent = Struct.new(:game, :card, :card_event, :options) do|new_class|
  def dry_run?
    options && options[:dry_run]
  end
end
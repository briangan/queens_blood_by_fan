module CardSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name [Rails.env, 'cards'].join('_')

    mapping do
      indexes :name, type: 'text'
      indexes :description, type: 'text'
      indexes :type, type: 'text'
      indexes :card_number, type: 'integer'
      indexes :category, type: 'text'
      indexes :pawn_rank, type: 'integer'
      indexes :power, type: 'integer'
      indexes :parent_card_id, type: 'integer'
    end

    # Would use if ElasticSearch is available; else would build 
    # ActiveRecord query in DB.
    def self.search(query, options = {})
      if query.present? && Elasticsearch.available?
        logger.debug "| Card searching w/ ElasticSearch: #{query} w/ #{options}"
        esearch(query, options)
      else
        cards = Card.includes(:card_tiles, :card_abilities)
        if query.present?
          cards = cards.where('name LIKE ? OR description LIKE ? OR card_number=?', "%#{query}%", "%#{query}%", query )
        end
        cards = cards.order(:card_number).page(options[:page]).limit(options[:limit]&.to_i || 20)
      end
    end

    def self.esearch(query, options = {})
      should_clauses = [
        {
          multi_match: {
            query: query,
            fields: ['name', 'description', 'type', 'category'],
            fuzziness: "AUTO"
          }
        }
      ]

      if query.to_s =~ /^\d+$/
        should_clauses << { term: { card_number: query.to_i } }
      end

      params = {
        query: {
          bool: {
            should: should_clauses
          }
        }
      }

      self.__elasticsearch__.search(params).records.page(params[:page] || 1).per(options[:limit] || 20)
    end
    
    
    # alias_method :elasticsearch_search, :esearch doesn't work for class method
    def self.elasticsearch_search(query, options = {})
      esearch(query, options)
    end

  end
end
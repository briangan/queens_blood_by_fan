namespace :elasticsearch do
  namespace :cards do
    desc "Reindex all Card records in Elasticsearch"
    task reindex: :environment do
      begin
        puts "Checking Elasticsearch availability..."
        client = Elasticsearch::Model.client
        client.ping
        puts "Elasticsearch is available"
      rescue => e
        puts "ERROR: Elasticsearch is not available: #{e.message}"
        exit 1
      end

      puts "Starting Card reindexing..."
      
      # Delete the existing index
      begin
        Card.__elasticsearch__.delete_index!
        puts "Deleted existing cards index"
      rescue Elastic::Transport::Transport::Errors::NotFound
        puts "No existing cards index found"
      end
      
      # Create the index with current mapping
      Card.__elasticsearch__.create_index!(force: true)
      puts "Created new cards index with current mapping"
      
      # Reindex all cards
      total_cards = Card.count
      puts "Found #{total_cards} cards to reindex"
      
      if total_cards > 0
        Card.__elasticsearch__.import
        puts "Successfully imported #{total_cards} cards"
        
        # Wait a moment for indexing to complete
        sleep 2
        
        # Verify the reindex
        search_result = Card.__elasticsearch__.search(query: { match_all: {} })
        indexed_count = search_result.response['hits']['total']['value']
        puts "Verified: #{indexed_count} cards are now indexed in Elasticsearch"
        
        if indexed_count == total_cards
          puts "✓ Reindex completed successfully!"
        else
          puts "⚠ Warning: Index count (#{indexed_count}) doesn't match database count (#{total_cards})"
        end
      else
        puts "No cards found to reindex"
      end
    end

    desc "Reindex all Card records in Elasticsearch (batch mode for large datasets)"
    task reindex_batch: :environment do
      begin
        puts "Checking Elasticsearch availability..."
        client = Elasticsearch::Model.client
        client.ping
        puts "Elasticsearch is available"
      rescue => e
        puts "ERROR: Elasticsearch is not available: #{e.message}"
        exit 1
      end

      puts "Starting Card batch reindexing..."
      
      # Delete the existing index
      begin
        Card.__elasticsearch__.delete_index!
        puts "Deleted existing cards index"
      rescue Elastic::Transport::Transport::Errors::NotFound
        puts "No existing cards index found"
      end
      
      # Create the index with current mapping
      Card.__elasticsearch__.create_index!(force: true)
      puts "Created new cards index with current mapping"
      
      # Reindex all cards in batches
      total_cards = Card.count
      batch_size = 100
      puts "Found #{total_cards} cards to reindex in batches of #{batch_size}"
      
      if total_cards > 0
        Card.__elasticsearch__.import(batch_size: batch_size) do |response|
          puts "Indexed batch: #{response['items'].size} cards"
        end
        puts "Successfully reindexed #{total_cards} cards"
        
        # Wait a moment for indexing to complete
        sleep 2
        
        # Verify the reindex
        search_result = Card.__elasticsearch__.search(query: { match_all: {} })
        indexed_count = search_result.response['hits']['total']['value']
        puts "Verified: #{indexed_count} cards are now indexed in Elasticsearch"
        
        if indexed_count == total_cards
          puts "✓ Batch reindex completed successfully!"
        else
          puts "⚠ Warning: Index count (#{indexed_count}) doesn't match database count (#{total_cards})"
        end
      else
        puts "No cards found to reindex"
      end
    end

    desc "Check Elasticsearch index status for Cards"
    task status: :environment do
      begin
        puts "Checking Elasticsearch availability..."
        client = Elasticsearch::Model.client
        client.ping
        puts "Elasticsearch is available"
      rescue => e
        puts "ERROR: Elasticsearch is not available: #{e.message}"
        exit 1
      end
      
      begin
        # Get index stats
        stats = Card.__elasticsearch__.client.indices.stats(index: Card.index_name)
        index_name = Card.index_name
        
        puts "Elasticsearch Cards Index Status:"
        puts "================================"
        puts "Index name: #{index_name}"
        puts "Total documents: #{stats.dig('indices', index_name, 'total', 'docs', 'count') || 0}"
        puts "Index size: #{stats.dig('indices', index_name, 'total', 'store', 'size_in_bytes') || 0} bytes"
        
        # Compare with database count
        db_count = Card.count
        search_result = Card.__elasticsearch__.search(query: { match_all: {} })
        es_count = search_result.response['hits']['total']['value']
        
        puts "\nComparison:"
        puts "Database cards: #{db_count}"
        puts "Elasticsearch cards: #{es_count}"
        
        if db_count == es_count
          puts "✓ Index is in sync with database"
        else
          puts "⚠ Index is out of sync with database (difference: #{db_count - es_count})"
        end
        
      rescue Elastic::Transport::Transport::Errors::NotFound
        puts "No Elasticsearch index found for Cards"
        puts "Database cards: #{Card.count}"
        puts "Run 'rake elasticsearch:cards:reindex' to create and populate the index"
      end
    end

    desc "Create Elasticsearch index for Cards (without importing data)"
    task create_index: :environment do
      begin
        puts "Checking Elasticsearch availability..."
        client = Elasticsearch::Model.client
        client.ping
        puts "Elasticsearch is available"
      rescue => e
        puts "ERROR: Elasticsearch is not available: #{e.message}"
        exit 1
      end
      
      begin
        Card.__elasticsearch__.create_index!(force: true)
        puts "Successfully created Elasticsearch index for Cards: #{Card.index_name}"
      rescue => e
        puts "ERROR creating index: #{e.message}"
        exit 1
      end
    end

    desc "Delete Elasticsearch index for Cards"
    task delete_index: :environment do
      begin
        puts "Checking Elasticsearch availability..."
        client = Elasticsearch::Model.client
        client.ping
        puts "Elasticsearch is available"
      rescue => e
        puts "ERROR: Elasticsearch is not available: #{e.message}"
        exit 1
      end
      
      begin
        Card.__elasticsearch__.delete_index!
        puts "Successfully deleted Elasticsearch index for Cards: #{Card.index_name}"
      rescue Elastic::Transport::Transport::Errors::NotFound
        puts "No Elasticsearch index found for Cards"
      rescue => e
        puts "ERROR deleting index: #{e.message}"
        exit 1
      end
    end
  end

  desc "Reindex all models with Elasticsearch (currently just Cards)"
  task reindex_all: :environment do
    Rake::Task['elasticsearch:cards:reindex'].invoke
  end
end

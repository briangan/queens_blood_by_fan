Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200')

module Elasticsearch
  # Class variable to store last time confirmed Elasticsearch availability
  @last_checked = nil
  @is_available = false

  # Method to check ElasticSearch API availability
  def self.available?(expiration_time = 5.minutes)
    if @last_checked && Time.now < @last_checked + expiration_time
      return @is_available
    end
    @last_checked = Time.now
    client = Elasticsearch::Model.client
    client.ping
    @is_available = true
  rescue StandardError => e
    ApplicationRecord.logger.warn("Elasticsearch unavailable (@last_checked #{@last_checked}): #{e.message}")
    @is_available = false
  end
  @is_available
end
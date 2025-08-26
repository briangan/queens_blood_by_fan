Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200')

module Elasticsearch
  # Class variable to store last time confirmed Elasticsearch availability
  @last_checked = nil

  # Method to check ElasticSearch API availability
  def self.available?(expiration_time = 5.minutes)
    if @last_checked && Time.now < @last_checked + expiration_time
      return @last_checked
    end
    client = Elasticsearch::Model.client
    client.ping
    @last_checked = Time.now
  rescue StandardError => e
    @last_checked = nil
    ApplicationRecord.logger.warn("Elasticsearch unavailable: #{e.message}")
    false
  end
end
class ApplicationController < ActionController::Base
  def set_page_title_suffix(resource_or_collection)

    if resource_or_collection.is_a?(ActiveRecord::Base)
      @page_title_suffix = " - #{resource_or_collection.class.model_name.to_s.titleize} #{resource_or_collection.id}"
    elsif resource_or_collection.is_a?(ActiveRecord::Relation) && (first_of_collection = collection.first)
      @page_title_suffix = " - #{first_of_collection.class.model_name.plural.titleize}"
      @page_title_suffix << ", Page #{collection.current_page}" if collection.respond_to?(:current_page) # Kaminari .page needed
    end
    @page_title_suffix
  end
end

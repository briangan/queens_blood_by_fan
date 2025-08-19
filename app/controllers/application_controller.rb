class ApplicationController < ActionController::Base

  before_action :authenticate_user!

  # rescue AccessDenied exception
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to access_denied_path, alert: exception.message
  end

  ##
  # @page_title_suffix is used to append to the end of the page title in layouts/application.
  # 
  def set_page_title_suffix(resource_or_collection, model_name = nil)

    if resource_or_collection.is_a?(ActiveRecord::Base)
      @page_title_suffix = "#{(model_name || resource_or_collection.class.model_name.to_s).titleize} #{resource_or_collection.id}"
    elsif resource_or_collection.is_a?(ActiveRecord::Relation) && (first_of_collection = collection.first)
      @page_title_suffix = "#{(model_name || first_of_collection.class.model_name)}".pluralize.titleize
      @page_title_suffix << ", Page #{collection.current_page}" if collection.respond_to?(:current_page) # Kaminari .page needed
    end
    @page_title_suffix
  end
end

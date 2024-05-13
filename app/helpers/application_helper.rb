module ApplicationHelper
  def app_name
    t('app_name')
  end

  ##
  # Parts joined together: $app_name - ($collection or $record_name)
  def full_page_title
    s = app_name
    if respond_to?(:collection) && (first_of_collection = collection.first)
      s << " - #{first_of_collection.class.model_name.plural.titleize}, Page #{collection.current_page}"
    elsif respond_to?(:resource) && resource
      s << " - #{resource.class.model_name.human}"
    end
    s
  end
end

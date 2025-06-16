module ApplicationHelper
  def app_name
    t('app_name')
  end

  ##
  # Parts joined together: $app_name - @page_title_suffix
  def full_page_title
    s = app_name
    s << " - #{@page_title_suffix}" if @page_title_suffix.present?
    s
  end
end

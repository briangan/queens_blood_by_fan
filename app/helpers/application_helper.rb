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

  # Collect additional javascript packs to be included in the layout.
  # So later can render them all at once using one javascript_pack_tag call.
  # Usage: add_to_javascript_packs 'pack_name1', 'pack_name2
  def add_to_javascript_packs(*packs)
    @additional_javascript_packs ||= []
    @additional_javascript_packs.concat(packs)
  end

  ##
  # Because of multiple calls of javascript_pack_tag would raise duplicate pack error,
  # we need to collect all packs and render them at once.
  # So, in layout file, use <%= full_javascript_packs_tag %> instead of javascript_pack_tag.
  # At default, 'application' pack is always included.
  def full_javascript_packs_tag
    packs = ['application']
    packs.concat(@additional_javascript_packs) if @additional_javascript_packs.present?
    javascript_pack_tag(*packs, 'data-turbolinks-track': 'reload', 'as': 'script')
  end
end

module Admin::DocumentsHelper

  # Returns array of document sources for iframe display
  def usable_sources
    @document.sources.select{ |s| s.raw_html.present? && s.persisted? }.map{ |s| admin_source_path(s) } || []
  end
end

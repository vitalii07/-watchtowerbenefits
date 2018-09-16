module Admin::ProposalsHelper

  def document_state_map
    {}.tap do |map|
      Document.states.keys.each {|key| map[key.humanize] = key}
    end
  end
end

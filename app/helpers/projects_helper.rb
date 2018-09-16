module ProjectsHelper
  # format value
  def format_value(format, value)
    if format == :percent
      value.try(:extract_percent)
    elsif format == :float
      value.try(:extract_float)
    elsif format == :currency
      value.try(:extract_currency)
    else
      value
    end
  end

  def project_has_no_uploads
    return @project.policies.empty? && @project.proposals.empty?
  end

  def project_has_displayably_data
    return true if true_user.is_admin? # admins should see everything!

    columns = @project.policies + @project.proposals
    return columns.any?{ |column| column.state == 'finalized' && column.is_archived == false }
  end

  def sort_export_documents
    @documents.sort_by! do |d|
      index = @export_params[:sorting].index(d.id)
      [index.nil? ? 1 : 0, index || 0]
    end
  end

  # Per MS Excel
  # Make sure the name you entered does not exceed 31 characters.
  # Make sure the name does not contain any of the following characters: : \ / ? * [ or ]
  # Make sure you did not leave the name blank.
  def worksheet_safe_name(str)
    str = str.gsub(/\//, 'and')
    str.delete!("\/?*[]")
    str
  end

  def export_document_logos(documents)
    documents.map do |document|
      path = "#{Rails.root}/public#{document.carrier.logo_url}"
      if File.exists?(path)
        begin
          geo = Paperclip::Geometry.from_file(path)
          [document.carrier.logo_url, geo.width / geo.height]
        rescue => e
          [document.carrier.logo_url, -1]
        end
      else
        ['', -1]
      end
    end
  end

  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                       no_intra_emphasis: true,
                                       fenced_code_blocks: true,
                                       disable_indented_code_blocks: true,
                                       autolink: true,
                                       tables: true,
                                       underline: true,
                                       highlight: true
    )
    markdown.render(text).html_safe
  end

  # Excel cell defined name
  # [Project ID]_[Product Type]_[Attribute with Class]_[Class Number]_[Document Carrier Name]
  def export_cell_name(project_id, product_type_name, class_number, attribute_name, carrier_name)
    str = "#{project_id} #{product_type_name} #{class_number} #{attribute_name} #{carrier_name}"
    str = str.gsub(/[^0-9a-z]/i, '')
    str = 'P' + str
    str
  end
end

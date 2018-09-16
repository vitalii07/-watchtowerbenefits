# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  name           :string
#  employer_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  is_archived    :boolean          default(FALSE)
#  effective_date :date
#  view_options   :json
#

class Project < ActiveRecord::Base
  belongs_to :employer
  belongs_to :user
  has_many :documents
  has_many :policies, -> { where(document_type: 'Policy') }, class_name: 'Document'
  has_many :proposals, -> { where(document_type: 'Proposal') }, class_name: 'Document'
  has_many :project_product_types
  has_many :product_types, through: :project_product_types

  validates_presence_of :employer
  validates :effective_date, presence: true
  accepts_nested_attributes_for :project_product_types

  def mark_as_sold(proposal)
    return false if documents(true).any?(&:is_sold?) # reload associations

    proposal.update(is_sold: true)
  end

  def documents_for_export
    documents.finalized.where(is_archived: false).order('document_type asc, id asc').to_a
  end

  def name=(name)
    employer.update name: name
  end

  def contextual_contents
    dynamic_attribute_ids = product_types.map { |product_type| product_type.dynamic_attributes.pluck(:id) }.flatten.uniq
    ContextualContent.where(associatable_type: 'DynamicAttribute', associatable_id: dynamic_attribute_ids)
  end

  def premium_data

  end

  def class_rollup_data(options = {})
    rollup = {}
    # collapsed_rows = ((view_options || {})['rows'] || []).map(&:to_i)
    attributes_hash = DynamicAttribute
                        .where(id: product_types.joins(:dynamic_attributes).pluck('dynamic_attributes.id'))
                        .includes(:product_types).order(:attribute_order)
    document_list = documents.where(is_archived: false).to_a
    product_types.each do |product_type|
      rollup[product_type.id] = {}
      attributes = attributes_hash.select { |attr| attr.product_type_ids.empty? || attr.product_type_ids.include?(product_type.id) }

      attributes.each do |attribute|
        rollup[product_type.id][attribute.id] ||= []

        class_index = 1
        class_descriptions = []
        class_rows = []
        loop do
          class_encountered = false
          product_descriptions = []
          row_values = []
          document_list.each do |document|
            product = document.products.detect { |p| p.product_type_id == product_type.id }
            product_class = product && product.product_classes.detect { |pc| pc.class_number == class_index}
            if !product || !product_class
              product_descriptions.push :no_class
              row_values.push nil
              next
            end
            class_encountered = true
            product_descriptions.push product_class.dynamic_value_for(product_class.description_attribute)
            row_values.push product_class.dynamic_value_for(attribute)
          end

          if class_encountered
            class_descriptions << product_descriptions
            class_rows << {class: class_index, values: row_values}
            class_index += 1
          end
          break unless class_encountered
        end

        # roll up
        rollup[product_type.id][attribute.id] = rollup_data(class_rows, class_descriptions)
      end
    end

    rollup
  end

  def rollup_data(rows, descriptions = [])
    data = []
    rolled_up_list = []
    rows.count.times do |start_index|
      next if rolled_up_list.include? start_index
      main_class = rows[start_index]
      matched_index = [start_index]
      ((start_index + 1)..(rows.size - 1)).each do |matched|
        next if rolled_up_list.include? matched
        match_class = rows[matched]
        diff_ids = main_class[:values].each_with_index.map { |v, i| v.try(:value) != match_class[:values][i].try(:value) ? i : nil }.compact
        same_class = diff_ids.size == 0 || diff_ids.all? do |ii|
          # check if Unstated class exists and class description is also Unstated
          match_class[:values][ii].try(:value).blank? &&
            (descriptions[matched].blank? || descriptions[matched][ii].try(:value).blank?)
        end
        matched_index.push matched if same_class
      end
      rolled_up_list = (rolled_up_list << matched_index).flatten
      data.push(matched_index.map { |ii| rows[ii][:class] })
    end
    data
  end
end

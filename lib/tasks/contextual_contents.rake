require 'csv'

namespace :contextual_contents do
  desc 'Import data from CSV'
  task import: :environment do
    CSV.foreach(File.join(Rails.root, 'lib', 'tasks', 'data', 'contextual_content.csv'), headers: true) do |row|
      dyanmic_attribute = DynamicAttribute.find row['dynamic_attribute_id']
      content = ContextualContent.new(
        title: row['title'],
        content: row['primary_content'],
        content_type: row['type'],
        user_id: 4,
        associatable: dyanmic_attribute
      )
      content.save!
    end
  end
end
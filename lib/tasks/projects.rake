namespace :projects do
  desc "Update project view options for row collapsing"
  task update_view_options: :environment do
    Project.all.each do |p|
      view_options = p.view_options
      data = view_options["rows"] || []
      rows = {}
      if data.count > 0
        rollup_data = p.class_rollup_data
        data.each do |attr_id|
          rollup_data.each do |product_type_id, attributes|
            if attributes.keys.include?(attr_id)
              rows[attr_id] ||= []
              attributes[attr_id].each do |klasses|
                rows[attr_id].push klasses[0]
              end
              break
            end
          end
        end
      end

      view_options["rows"] = rows
      p.view_options = view_options
      p.save!
    end
  end
end
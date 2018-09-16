namespace :db do
  desc 'Merge Proposals and Policies into Documents'
  task merge_proposals_and_policies: :environment do
    proposals = Proposal.all
    policies = Policy.all

    [proposals, policies].flatten.each do |p|
      ActiveRecord::Base.record_timestamps = false

      document = Document.create sic_code: p.try(:sic_code),
                                 effective_date: p.try(:effective_date),
                                 proposal_duration: p.try(:proposal_duration),
                                 state: p.state,
                                 selectors: p.selectors,
                                 document_type: p.class.to_s,
                                 project_id: p.project_id,
                                 carrier_id: p.carrier_id,
                                 created_at: p.created_at,
                                 updated_at: p.updated_at

      p.products.each do |product|
        product.update document: document
      end

      p.sources.each do |source|
        source.update document: document
      end

      p.dynamic_values.each do |value|
        value.update parent: document
      end

      ActiveRecord::Base.record_timestamps = true
    end
  end

  desc 'Create default organizations for users'
  task default_organizations: :environment do
    watchtower = Organization.find_or_create_by(name: 'Watchtower Benefits')
    User.where("email LIKE ? OR email LIKE ?", '%watchtowerbenefits.com', '%polymathic.me').each{|user| user.update organization: watchtower }

    byrnebyrne = Organization.find_or_create_by(name: 'Byrne Byrne and Company')
    User.where("email LIKE ?", "%byrnebyrne.com").each{|user| user.update organization: byrnebyrne }
  end

  desc 'Add admin role for admins'
  task create_admin_roles: :environment do
    User.where(is_admin: true).each{|user| user.add_role('admin') }
  end
end

require 'rails_helper'

describe 'deviations test for Estwing project', :business do

  context 'DB Test' do
    it 'should load the database properly' do
      expect(Project.all==[]). to be_falsey
    end
  end

  context 'Pol: unstated Pro: X->anything should not flag' do
    it 'should expect policy_value to be nil and propsed value not to be flagged' do

      # get Employer id
      employerID = Employer.find_by!(name: 'Estwing Manufacturing').id

      # get Estwing Manufacturing Project
      project = Project.find_by!(employer_id: employerID)

      # get current Hartford policy document_id and cigna_proposal
      hartford_policyID = project.policies[0].id
      cigna_proposalID = project.proposals[1].id

      # find Basic Life / AD&D product in the current policy and proposal documents
      policyProduct = Product.all.select{|product| product.document_id == hartford_policyID && product.product_type.name == "Basic Life / AD&D"}[0]
      proposalProduct = Product.all.select{|product| product.document_id == cigna_proposalID && product.product_type.name == "Basic Life / AD&D"}[0]

      # get the product classes
      policyProductClasses = policyProduct.product_classes
      proposalProductClasses = proposalProduct.product_classes

      # get dynamic_values in class 1
      policyClass1DynamicValues = (policyProductClasses.select{|val| val.class_number == 1})[0].dynamic_values
      proposalClass1DynamicValues = (proposalProductClasses.select{|val| val.class_number == 1})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass1ClassDescription = policyClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass1ClassDescription = proposalClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]

      # get dynamic_values in class 2
      policyClass2DynamicValues = (policyProductClasses.select{|val| val.class_number == 2})[0].dynamic_values
      proposalClass2DynamicValues = (proposalProductClasses.select{|val| val.class_number == 2})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass2ClassDescription = policyClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass2ClassDescription = proposalClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]


      # update value to something else to make sure value in class 2 is being compared and not class 1
      policyClass1ClassDescription.update(value: "Devang")

      # set value in class 2 to unstated in the policy
      policyClass2ClassDescription.update(value: nil)

      # set Proposal value in class 2 to anything
      proposalClass2ClassDescription.update(value: "Shaheeb")

      # expect proposalClass2ClassDescription to not be flagged
      expect(proposalClass2ClassDescription.comparison_flag).to eq "not_compared"
    end
  end

  context 'Pol: X Pro: anything->unstated should not be flagged' do
    it 'should expect propsed value to not be flagged' do

      # get Employer id
      employerID = Employer.find_by!(name: 'Estwing Manufacturing').id

      # get Estwing Manufacturing Project
      project = Project.find_by!(employer_id: employerID)

      # get current Hartford policy document_id and cigna_proposal
      hartford_policyID = project.policies[0].id
      cigna_proposalID = project.proposals[1].id

      # find Basic Life / AD&D product in the current policy and proposal documents
      policyProduct = Product.all.select{|product| product.document_id == hartford_policyID && product.product_type.name == "Basic Life / AD&D"}[0]
      proposalProduct = Product.all.select{|product| product.document_id == cigna_proposalID && product.product_type.name == "Basic Life / AD&D"}[0]

      # get the product classes
      policyProductClasses = policyProduct.product_classes
      proposalProductClasses = proposalProduct.product_classes

      # get dynamic_values in class 1
      policyClass1DynamicValues = (policyProductClasses.select{|val| val.class_number == 1})[0].dynamic_values
      proposalClass1DynamicValues = (proposalProductClasses.select{|val| val.class_number == 1})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass1ClassDescription = policyClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass1ClassDescription = proposalClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]

      # get dynamic_values in class 2
      policyClass2DynamicValues = (policyProductClasses.select{|val| val.class_number == 2})[0].dynamic_values
      proposalClass2DynamicValues = (proposalProductClasses.select{|val| val.class_number == 2})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass2ClassDescription = policyClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass2ClassDescription = proposalClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]

      # update value to something else to make sure value in class 2 is being compared and not class 1
      policyClass1ClassDescription.update(value: "Devang")

      # set value in class 2 to something
      policyClass2ClassDescription.update(value: "Richard")

      # set Proposal value in class 2 to unstated
      proposalClass2ClassDescription.update(value: nil)

      # expect proposalClass2ClassDescription to not be flagged
      expect(proposalClass2ClassDescription.comparison_flag).to eq "not_compared"
    end
  end

  context 'Pol: X Pro: X should not be flagged' do
    it 'should expect propsed value to not be flagged' do

      # get Employer id
      employerID = Employer.find_by!(name: 'Estwing Manufacturing').id

      # get Estwing Manufacturing Project
      project = Project.find_by!(employer_id: employerID)

      # get current Hartford policy document_id and cigna_proposal
      hartford_policyID = project.policies[0].id
      cigna_proposalID = project.proposals[1].id

      # find Basic Life / AD&D product in the current policy and proposal documents
      policyProduct = Product.all.select{|product| product.document_id == hartford_policyID && product.product_type.name == "Basic Life / AD&D"}[0]
      proposalProduct = Product.all.select{|product| product.document_id == cigna_proposalID && product.product_type.name == "Basic Life / AD&D"}[0]

      # get the product classes
      policyProductClasses = policyProduct.product_classes
      proposalProductClasses = proposalProduct.product_classes

      # get dynamic_values in class 1
      policyClass1DynamicValues = (policyProductClasses.select{|val| val.class_number == 1})[0].dynamic_values
      proposalClass1DynamicValues = (proposalProductClasses.select{|val| val.class_number == 1})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass1ClassDescription = policyClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass1ClassDescription = proposalClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]

      # get dynamic_values in class 2
      policyClass2DynamicValues = (policyProductClasses.select{|val| val.class_number == 2})[0].dynamic_values
      proposalClass2DynamicValues = (proposalProductClasses.select{|val| val.class_number == 2})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass2ClassDescription = policyClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass2ClassDescription = proposalClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]

      # update value to something else to make sure value in class 2 is being compared and not class 1
      policyClass1ClassDescription.update(value: "Devang")

      # set value in class 2 to something
      policyClass2ClassDescription.update(value: "Ryan")

      # set Proposal value in class 2 to anything
      proposalClass2ClassDescription.update(value: "Ryan")

      # expect proposalClass2ClassDescription to not be flagged
      expect(proposalClass2ClassDescription.comparison_flag).to eq "not_compared"
    end
  end

  context 'Pol: X Pro: Y should be flagged' do
    it 'should expect propsed value to not be flagged' do

      # get Employer id
      employerID = Employer.find_by!(name: 'Estwing Manufacturing').id

      # get Estwing Manufacturing Project
      project = Project.find_by!(employer_id: employerID)

      # get current Hartford policy document_id and cigna_proposal
      hartford_policyID = project.policies[0].id
      cigna_proposalID = project.proposals[1].id

      # find Basic Life / AD&D product in the current policy and proposal documents
      policyProduct = Product.all.select{|product| product.document_id == hartford_policyID && product.product_type.name == "Basic Life / AD&D"}[0]
      proposalProduct = Product.all.select{|product| product.document_id == cigna_proposalID && product.product_type.name == "Basic Life / AD&D"}[0]

      # get the product classes
      policyProductClasses = policyProduct.product_classes
      proposalProductClasses = proposalProduct.product_classes

      # get dynamic_values in class 1
      policyClass1DynamicValues = (policyProductClasses.select{|val| val.class_number == 1})[0].dynamic_values
      proposalClass1DynamicValues = (proposalProductClasses.select{|val| val.class_number == 1})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass1ClassDescription = policyClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass1ClassDescription = proposalClass1DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]

      # get dynamic_values in class 2
      policyClass2DynamicValues = (policyProductClasses.select{|val| val.class_number == 2})[0].dynamic_values
      proposalClass2DynamicValues = (proposalProductClasses.select{|val| val.class_number == 2})[0].dynamic_values

      # get dynamic value for the class description dynamic_attribute
      policyClass2ClassDescription = policyClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]
      proposalClass2ClassDescription = proposalClass2DynamicValues.select{|val| val.dynamic_attribute.display_name == "Class Description"}[0]

      # update value to something else to make sure value in class 2 is being compared and not class 1
      policyClass1ClassDescription.update(value: "Devang")

      # set value in class 2 to something
      policyClass2ClassDescription.update(value: "something")

      # set Proposal value in class 2 to anything
      proposalClass2ClassDescription.update(value: "WatchTower")

      # expect proposalClass2ClassDescription to be flagged
      expect(proposalClass2ClassDescription.comparison_flag).to eq "equivalent"
    end
  end
end

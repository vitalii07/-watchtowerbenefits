require 'rails_helper'

describe 'create project' do
  let(:user) { create(:user) }

  it 'should create project and upload file', :business, js: true do
    login(user)

    find_link_with_text('Add New Project').trigger('click')
    expect(page).to have_css('h2', text: 'Create New RFP')

    # enter project info
    within '.wt-formfield' do
      fill_in 'employer-name', with: 'WatchTower Integration Test'
      fill_in 'effective-date', with: '1/1/2016'
      click_button 'Next'
    end

    # add all product types and check In-force
    expect(page).to have_css('h2', text: 'Enter RFP Product Info')
    expect(page).to have_css('.wt-product-type')
    ProductType.find_each do |product_type|
      all('.wt-product-type').last.find('select').find("option[value='#{product_type.id}']").select_option
      all('.wt-product-type').last.find('input[type="checkbox"]').set(true)
      find_button_with_text('Add Product').trigger('click')
    end
    click_button 'Next'

    # attach policy document
    expect(page).to have_css('h2', text: 'Upload Current Policy File(s)')
    drop_in_dropzone Rails.root.join('spec/fixtures/osa.html')
    click_button 'Upload'

    # thank you page
    expect(page).to have_css('h2', text: 'Thank You!')
    click_button 'View Project'

    # check redirected to project detail page
    expect(page).to have_content('WatchTower Integration Test')
    project = Project.order(:created_at).last
    expect(project.employer.name).to eq('WatchTower Integration Test')
    expect(project.effective_date).to eq(Date.parse('2016-01-01'))
    document = project.policies.first
    expect(document.sources.first.file.exists?).to be_truthy
  end

  it 'should export xlsx file', :business, js: true do
    Project.update_all(user_id: user.id)
    login(user)

    click_link 'Estwing Manufacturing'
    expect(page).to have_content('Estwing Manufacturing')

    find_link_with_text('Export as XLS').trigger('click')
    expect(page).to have_css('h2', text: 'Export This Project')
    click_button 'Export'

    expect(page.response_headers['Content-Disposition']).to include("filename=\"export_177.xlsx\"")
  end
end

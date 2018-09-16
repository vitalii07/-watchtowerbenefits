require 'rails_helper'

RSpec.describe ProjectsController, :type => :controller do

  let(:user) { create(:user) }
  before(:each) do
    allow_any_instance_of(ProjectsController).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    it 'lists all projects' do
      projects = create_list(:project, 5, user: user)
      get :index
      expect(assigns[:projects]).to match_array projects
    end
  end

  describe "GET show" do
    it "assigns the project as @project" do
      project = create(:project, user: user)
      get :show, {id: project.id}
      expect(assigns(:project)).to eq(project)
    end
  end

  describe "PATCH #mark_as_sold" do
    it 'should mark proposal as sold' do
      proposal = create(:document, project: create(:project, user: user))
      expect {
        patch :mark_as_sold, {id: proposal.project.id, proposal_id: proposal.id}, format: :json
        proposal.reload
      }.to change(proposal, :is_sold).from(false).to(true)
    end

    it 'should not mark proposal as sold if any of proposal is already sold' do
      proposal = create(:document, project: create(:project, user: user))
      proposal1 = create(:document, project: proposal.project)
      expect {
        patch :mark_as_sold, {id: proposal.project.id, proposal_id: proposal.id}, format: :json
        proposal.reload
      }.to change(proposal, :is_sold).from(false).to(true)

      patch :mark_as_sold, {id: proposal1.project.id, proposal_id: proposal1.id}, format: :json
      proposal1.reload
      expect(proposal1.is_sold).to eql(false)
    end
  end

  describe "PATCH #update" do
    before do
      @project = create(:project, user: user)
    end

    it 'should update project attributes' do
      expect {
        patch :update, id: @project.id, project: {effective_date: Date.tomorrow}, format: :json
        @project.reload
      }.to change(@project, :effective_date).from(1.month.from_now.to_date).to(Date.tomorrow)
    end

    it 'should validate required fields' do
      patch :update, id: @project.id, project: {effective_date: nil}, format: :json
      expect(JSON.parse(response.body).keys).to include('effective_date')
    end
  end

  describe "POST create" do
    before(:each) do
      @project_params = {effective_date: Date.today}
    end

    it "creates a project" do
      expect {
        post :create, project: @project_params.merge(employer_id: create(:employer, user: user).id), format: :json
      }.to change(Project, :count).by(1)
    end

    it "shows error message for required fields" do
      post :create, project: {employer_id: create(:employer, user: user).id}, format: :json
      expect(JSON.parse(response.body).keys).to include('errors')
    end

    it "creates a project and assigns the existing employer" do
      employer = create(:employer, user: user)
      expect {
        post :create, project: @project_params.merge(employer_id: employer.id), format: :json
      }.to change(Employer, :count).by(0)
    end

    it "creates a new employer when only name is supplied" do
      expect {
        post :create, employer_name: "ABC", project: @project_params, format: :json
      }.to change(Employer, :count).by(1)
    end

    it "creates a new employer when name and id is supplied but name does not match given employer" do
      employer = create(:employer, name: "CBA")
      expect {
        post :create, employer_name: "ABC", project: @project_params, format: :json
      }.to change(Employer, :count).by(1)
    end

    it "creates a project and assigns the existing employer when name matches" do
      employer = create(:employer, user: user)
      expect {
        post :create, employer_name: employer.name, project: @project_params, format: :json
      }.to change(Employer, :count).by(0)
    end
  end

  describe "GET #export" do
    before do
      @project = create(:project, user: user)
      @documents = create_list(:document, 5, :finalized, project: @project)
      @policy = create(:document, :policy, :finalized, project: @project)
    end

    it 'should list only finalized documents' do
      @documents.each { |d| d.update(state: :data_entry) }
      get :export, {id: @project.id, format: :xlsx}
      documents = assigns[:documents]
      expect(documents.map(&:id)).to eql([@policy.id])
    end

    it 'should sort export documents by policy and id' do
      get :export, {id: @project.id, format: :xlsx}
      documents = assigns[:documents]
      expect(documents.map(&:id)).to eql([@policy.id] + @documents.map(&:id))
    end
  end
end

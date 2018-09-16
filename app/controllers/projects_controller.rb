class ProjectsController < ApplicationController
  include ProjectsHelper

  before_action :authenticate_user!
  before_action :load_project, only: [:show, :update, :destroy, :edit, :export, :mark_as_sold, :update_view_options]

  def update
    @project.update(project_params)

    if @project.valid?
      respond_to do |format|
        format.json { render json: @project, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    employer = employer_from_params
    attributes = project_params
    attributes.delete(:employer_id)
    @project = current_user.projects.create(attributes.merge(employer: employer))

    respond_to do |format|
      format.html # redirect_to projects_path
      format.json do
        if @project.valid?
          render json: @project
        else
          render json: {errors: @project.errors.full_messages}, status: :unprocessable_entity
        end
      end
    end
  end

  def index
    @projects = current_user.all_projects.includes(:employer)
    respond_to do |format|
      format.html # render index.html.slim
      format.json do
        eager_load_display_attributes(@projects)
        render json: @projects
      end
    end
  end

  def show
    eager_load_display_attributes(@project)
    respond_to do |format|
      format.html # render show.html.slim
      format.js { render json: @project }
    end
  end

  def export
    @export_params = export_params
    @documents = @project.documents_for_export.to_a
    sort_export_documents
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"export_#{@project.id}.xlsx\""
      }
    end
  end

  def mark_as_sold
    proposal = @project.proposals.find_by(id: params[:proposal_id])

    if @project.mark_as_sold(proposal)
      render json: @project, status: :ok
    else
      render json: @project, status: :unprocessable_entity
    end
  end

  def update_view_options
    @project.view_options = params.require(:project).permit![:view_options]
    if @project.save
      render json: @project.view_options, status: :ok
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  private

  def export_params
    collapsed_rows = {}
    (params[:rows] || {}).each { |attr_id, klasses| collapsed_rows[attr_id.to_i] = klasses.map(&:to_i) }
    {
      collapsed_rows: collapsed_rows,
      sorting: (params[:sorting] || []).map(&:to_i),
      advanced_products: Set.new((params[:advanced] || []).map(&:to_i)),
      volumes: Hash[(params[:volumes] || {}).map{ |k, v| [k.to_i, v.blank? ? nil : v.to_i] }]
    }
  end

  def employer_from_params
    employer = current_user.employers.where(id: params[:project][:employer_id]).first
    if employer.nil? || (params[:employer_name] && params[:employer_name].downcase != employer.name.downcase)
      employer = current_user.employers.find_or_create_by(name: params[:employer_name]) if params[:employer_name]
    end
    employer
  end

  def project_params
    # Employer may be specified by name when creating a project so use special logic
    # to create or set the employer
    params.require(:project).permit(:name, :employer_id, :effective_date, project_product_types_attributes: [:id, :product_type_id, :inforce, :rate, :commission], metadata: [:collapsed_row_id]).tap do |params_hash|
      employer = employer_from_params
      params_hash[:employer_id] = employer.id if employer
    end
  end

  def load_project
    @project = current_user.all_projects.find(params[:id])
  end

  def eager_load_display_attributes(association)
    ActiveRecord::Associations::Preloader.new.preload(association, documents: {
         products: {
           product_classes: {
             dynamic_values: :dynamic_attribute
           }
         }
       })
    # association.includes()
  end
end

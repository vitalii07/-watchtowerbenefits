#-----------  Requirements  -----------#

# for documentation on the React Wizard component
# see https://github.com/jacobrosenthal/react-wizard

Modal = require('components/common/modal')

CreateNewRFP    = require('components/modals/steps/create_new_rfp')
RFPProductInfo  = require('components/modals/steps/rfp_product_info')
UploadPolicy    = require('components/modals/steps/upload_policy')
NoCurrentPolicy = require('components/modals/steps/no_current_policy')
ThankYou        = require('components/modals/steps/thank_you')

#-----------  React Componet Class  -----------#

NewProjectWizard = React.createClass

  getDefaultProps: ->
    return { projectData: {} }

  getInitialState: ->
    return { step: 1, isModalOpen: false }

  #-----------  Event Handlers  -----------#

  _openModal: ->
    @setState({ isModalOpen: true })

  _closeModal: ->
    @setState({ isModalOpen: false })

  _goToStep: (step) ->
    @setState({ step: step })

  _saveValues: (new_data) ->
    @setProps({ projectData: _.extend(@props.projectData, new_data) })

  #-----------  HTML Element Render  -----------#

  render: ->
    switch @state.step
      when 1
        stepComponent = (
          `<CreateNewRFP
            projectData={this.props.projectData}
            saveValues={this._saveValues}
            goToStep={this._goToStep}
          />`
        )
      when 2
        stepComponent = (
          `<RFPProductInfo
            projectData={this.props.projectData}
            saveValues={this._saveValues}
            goToStep={this._goToStep}
          />`
        )
      when 3
        stepComponent = (
          `<UploadPolicy
            projectData={this.props.projectData}
            goToStep={this._goToStep}
          />`
        )
      when 4
        stepComponent = (
          `<NoCurrentPolicy
            projectData={this.props.projectData}
            goToStep={this._goToStep}
          />`
        )
      when 5
        stepComponent = (
          `<ThankYou
            projectData={this.props.projectData}
          />`
        )

    return (
      `<span>
        <a className="wt-page-header__link wt-page-header__link--button" onClick={this._openModal}>
          <i className="icon-plus"></i>Add New Project
        </a>

        <Modal isOpen={this.state.isModalOpen}>
          {stepComponent}
        </Modal>
      </span>`
    )

#-----------  Export  -----------#

module.exports = NewProjectWizard
window.NewProjectWizard = NewProjectWizard

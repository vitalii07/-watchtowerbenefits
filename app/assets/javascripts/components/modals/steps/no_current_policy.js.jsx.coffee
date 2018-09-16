#-----------  React Componet Class  -----------#

NoCurrentPolicy = React.createClass

  propTypes:
    projectData : React.PropTypes.object.isRequired
    goToStep    : React.PropTypes.func.isRequired

  #-----------  HTML Element Render  -----------#

  render: ->
    return (
      `<div className="wt-new-project-wizard__step wt-new-project-wizard__step--four">
        <h2 className="wt-modal__title">No Current Policy?</h2>
        <p>Are you sure there's no current policy? Once you create this project, you will no longer be able to add the current policy and compare it to new proposals.</p>

        <button onClick={this._continue}>Correct, there is no current policy</button>
        <button className="button-alt" onClick={this._goBack}>Upload current policy</button>
      </div>`
    )

  #-----------  Save & Continue  -----------#

  _continue: ->
    window.location = "/projects/#{@props.projectData.project.id}"

  _goBack: ->
    @props.goToStep(3)

#-----------  Export  -----------#

module.exports = NoCurrentPolicy

#-----------  React Componet Class  -----------#

ThankYou = React.createClass

  propTypes:
    projectData : React.PropTypes.object.isRequired

  #-----------  HTML Element Render  -----------#

  render: ->
    return (
      `<div className="wt-new-project-wizard__step wt-new-project-wizard__step--five">
        <h2 className="wt-modal__title">Thank You!</h2>
        <p>We will begin processing your current policy file(s) and notify you via email when we've finished. This typically takes under 24 hours.</p>

        <button onClick={this._continue}>View Project</button>
      </div>`
    )

  #-----------  Save & Continue  -----------#

  _continue: ->
    window.location = "/projects/#{@props.projectData.project.id}"

#-----------  Export  -----------#

module.exports = ThankYou

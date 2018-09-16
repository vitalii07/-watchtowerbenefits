#-----------  React Componet Class  -----------#

CreateNewRFP = React.createClass

  propTypes:
    projectData : React.PropTypes.object.isRequired
    saveValues  : React.PropTypes.func.isRequired
    goToStep    : React.PropTypes.func.isRequired

  getInitialState: ->
    name = @props.projectData.employer_name || null
    date = @props.projectData.effective_date || null

    return {
      employerName  : name
      effectiveDate : date
      isValid       : @_isValid(name, date)
    }

  #-----------  Event Handlers  -----------#

  _isValid: (name, date) ->
    has_date = moment(date).isValid()
    has_name = !_.isEmpty(name)
    return (has_name && has_date)

  _setEffectiveDate: (evt) ->
    date = evt.target.value
    
    @setState {
      effectiveDate : date
      isValid       : @_isValid(@state.employerName, date)
    }

  _setEmployerName: (evt) ->
    @setState {
      employerName : evt.target.value
      isValid      : @_isValid(evt.target.value, @state.effectiveDate)
    }

  #-----------  HTML Element Render  -----------#

  render: ->
    return (
      `<div className="wt-new-project-wizard__step wt-new-project-wizard__step--one">
        <small>Step 1 of 3</small>

        <h2 className="wt-modal__title">Create New RFP</h2>

        <div className="wt-formfield">
          <label>Employer Name</label>
          <input type="text" value={this.state.employerName} name="employer-name" onChange={this._setEmployerName} />

          <label>Effective Date</label>
          <input type="date" value={this.state.effectiveDate} name="effective-date" onChange={this._setEffectiveDate} placeholder='mm/dd/yyyy'/>

          <div className="wt-new-project-wizard__progress-buttons">
            <button disabled={!this.state.isValid} onClick={this._saveAndContinue}>Next</button>
          </div>
        </div>
      </div>`
    )

  #-----------  Save & Continue  -----------#

  _saveAndContinue: ->
    @props.saveValues(
      employer_name  : @state.employerName
      effective_date : @state.effectiveDate
    )
    @props.goToStep(2)

#-----------  Export  -----------#

module.exports = CreateNewRFP

#-----------  Requirements  -----------#

# for documentation on the Dropzone library
# see http://www.dropzonejs.com/

Dropzone = require('components/common/dropzone')

#-----------  React Componet Class  -----------#

UploadCurrentPolicy = React.createClass

  propTypes:
    projectData : React.PropTypes.object.isRequired
    goToStep    : React.PropTypes.func.isRequired

  getInitialState: ->
    return { dropzoneReady : false }

  #-----------  Event Handlers  -----------#

  _dropzoneReady: ->
    @setState({ dropzoneReady: true })

  _dropzoneNotReady: ->
    @setState({ dropzoneReady: false })

  _onSubmit: ->
    @refs.dzComponent.submit()

  #-----------  HTML Element Render  -----------#

  render: ->
    url = "/projects/#{@props.projectData.project.id}/documents"
    postData = {"document[document_type]": "Policy"}

    return (
      `<div className="wt-new-project-wizard__step wt-new-project-wizard__step--two">
        <small>Step 3 of 3</small>

        <h2 className="wt-modal__title">Upload Current Policy File(s)</h2>

        <div className="wt-formfield">
          <Dropzone
            url={url}
            ref="dzComponent"
            postData={postData}
            uploadText="current policy file(s)"
            dropzoneReady={this._dropzoneReady}
            dropzoneNotReady={this._dropzoneNotReady}
            dropzoneComplete={this._continueAfterUpload}
          >
          </Dropzone>

          <button className="button-alt" onClick={this._continueNoUpload}>No current policy!</button>

          <div className="wt-new-project-wizard__progress-buttons">
            <button className="button-alt" onClick={this._goBack}>Prev</button>
            <button onClick={this._onSubmit} disabled={!this.state.dropzoneReady}>Upload</button>
          </div>
        </div>
      </div>`
    )

  #-----------  Save & Continue  -----------#

  _goBack: ->
    @props.goToStep(2)

  _continueAfterUpload: ->
    setTimeout( =>
      @props.goToStep(5)
    , 1500)

  _continueNoUpload: ->
    @props.goToStep(4)

#-----------  Export  -----------#

module.exports = UploadCurrentPolicy

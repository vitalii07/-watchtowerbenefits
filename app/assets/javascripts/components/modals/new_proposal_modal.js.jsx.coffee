#-----------  Requirements  -----------#

# for documentation on the Dropzone library
# see http://www.dropzonejs.com/

Modal    = require('components/common/modal')
Dropzone = require('components/common/dropzone')

#-----------  React Componet Class  -----------#

NewProposalModal = React.createClass

  propTypes:
    projectId : React.PropTypes.any.isRequired

  getInitialState: ->
    return {
      dropzoneReady : false
      isModalOpen   : false
    }

  #-----------  Event Handlers  -----------#

  _openModal: ->
    @setState({ isModalOpen: true })

  _closeModal: ->
    @setState({ isModalOpen: false })

  _dropzoneReady: () ->
    @setState({ dropzoneReady: true })

  _dropzoneNotReady: () ->
    @setState({ dropzoneReady: false })

  _onSubmit: (done) ->
    @refs.dzComponent.submit()

  #-----------  HTML Element Render  -----------#

  render: ->
    url = "/projects/#{@props.projectId}/documents"
    postData = {"document[document_type]": "Proposal"}

    return (
      `<span>
        <a className="wt-page-header__link wt-page-header__link--button" onClick={this._openModal}>
          <i className="icon-plus"></i>Upload New Proposal
        </a>

        <Modal isOpen={this.state.isModalOpen} title="Add file(s) for one new proposal">
          <div className="wt-formfield">
            <Dropzone
              url={url}
              ref="dzComponent"
              postData={postData}
              uploadText="new proposal file(s)"
              dropzoneReady={this._dropzoneReady}
              dropzoneNotReady={this._dropzoneNotReady}
              dropzoneComplete={this._continueAfterUpload}
            />

            <button onClick={this._onSubmit} disabled={!this.state.dropzoneReady}>Upload</button>
          </div>
        </Modal>
      </span>`
    )

  #-----------  Save & Continue  -----------#

  _continueAfterUpload: () ->
    setTimeout( =>
      window.location = "/projects/#{@props.projectId}"
    , 1500)

#-----------  Export  -----------#

module.exports = NewProposalModal
window.NewProposalModal = NewProposalModal

#-----------  Requirements  -----------#

Modal               = require('components/common/modal')
LocalStorageAdapter = require('utils/local_storage_adapter')

#-----------  React Componet Class  -----------#

ExportProjectModal = React.createClass

  propTypes:
    exportURL : React.PropTypes.string.isRequired
    projectId : React.PropTypes.any.isRequired

  getInitialState: ->
    return {
      isModalOpen : false
    }

  #-----------  Event Handlers  -----------#

  _openModal: ->
    @setState({ isModalOpen: true })

  _closeModal: ->
    @setState({ isModalOpen: false })

  #-----------  HTML Element Render  -----------#

  render: ->
    return (
      `<span>
        <a className="wt-page-header__link" onClick={this._openModal}>
          <i className="icon-export"></i>Export as XLS
        </a>

        <Modal isOpen={this.state.isModalOpen} title="Export This Project">
          <p>You are requesting an XLS export of the data for this project. Please note that all data from visible rows and columns will be exported. Archive any unwanted proposals and hide all rows you do not want to be included in your export.</p>
          <button onClick={this._continue}>Export</button>
        </Modal>
      </span>`
    )

  #-----------  Save & Continue  -----------#

  _continue: () ->
    ui_data = LocalStorageAdapter.getAllProjectData(@props.projectId)
    window.location = @props.exportURL + '?' + $.param(ui_data)

#-----------  Export  -----------#

module.exports = ExportProjectModal
window.ExportProjectModal = ExportProjectModal

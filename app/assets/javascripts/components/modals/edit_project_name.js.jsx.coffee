#-----------  Requirements  -----------#

Modal = require('components/common/modal')

#-----------  React Componet Class  -----------#

EditProjectName = React.createClass

  propTypes:
    projectId : React.PropTypes.any.isRequired
    name      : React.PropTypes.string

  getInitialState: ->
    return (
      isModalOpen: false
    )

  #-----------  Event Handlers  -----------#

  _openModal: ->
    @setState({ isModalOpen: true })

  _setName: (event) ->
    @setProps({ name: event.target.value })

  #-----------  HTML Element Render  -----------#

  render: ->
    `<div>
      <div className="wt-dropdown">
        <i className="icon-down"></i>
        <ul className="wt-dropdown__block">
          <li>
            <a onClick={this._openModal}>
              Edit project name
            </a>
          </li>
        </ul>
      </div>

      <Modal isOpen={this.state.isModalOpen} title="Edit Project Name">
        <div className="wt-formfield">
          <label>Project Name</label>
          <input type="text" defaultValue={this.props.name} onChange={this._setName} />

          <button onClick={this._update}>Update</button>
        </div>
      </Modal>
    </div>`

  #-----------  update  -----------#

  _update: (event) ->
    $.ajax
      url: "/projects/#{@props.projectId}"
      dataType: 'json'
      method: 'PUT'
      data:
        project:
          name: @props.name
      success: ->
        location.reload()

#-----------  Export  -----------#

module.exports = EditProjectName
window.EditProjectName = EditProjectName

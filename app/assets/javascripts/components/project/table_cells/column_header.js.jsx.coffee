#-----------  Requirements  -----------#

DataTableActions = require('actions/data_table')
PureRenderMixin  = require('react-addons-pure-render-mixin')

#-----------  React Componet Class  -----------#

ColumnHeader = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    columnID     : React.PropTypes.number
    filenames    : React.PropTypes.array
    carrierLogo  : React.PropTypes.string
    carrierName  : React.PropTypes.string
    orderIndex   : React.PropTypes.number
    canMoveLeft  : React.PropTypes.bool
    canMoveRight : React.PropTypes.bool
    isVisible    : React.PropTypes.bool
    isPolicy     : React.PropTypes.bool
    isLocked     : React.PropTypes.bool
    documentType : React.PropTypes.string

  getDefaultProps: ->
    return {
      filenames    : []
      carrierLogo  : null
      carrierName  : null
      orderIndex   : null
      canMoveLeft  : false
      canMoveRight : false
      isVisible    : false
      isPolicy     : false
      isLocked     : false
      documentType : 'Proposal'
    }

  #-----------  Event Handlers  -----------#

  _selectAsSold: (evt) ->
    return false if @props.isPolicy
    DataTableActions.selectColumnAsSold(@props.columnID)

  _archiveProject: (evt) ->
    return false if @props.isPolicy
    DataTableActions.archiveColumn(@props.columnID)

  _deleteProject: (evt) ->
    return false if @props.isPolicy
    DataTableActions.deleteColumn(@props.columnID)

  _moveColumnLeft: (evt) ->
    return false unless @props.canMoveRight || !@props.isPolicy
    toIndex = @props.orderIndex - 1
    DataTableActions.resortColumn(@props.columnID, @props.orderIndex, toIndex)

  _moveColumnRight: (evt) ->
    return false unless @props.canMoveRight || !@props.isPolicy
    toIndex = @props.orderIndex + 1
    DataTableActions.resortColumn(@props.columnID, @props.orderIndex, toIndex)

  #-----------  HTML Element Render  -----------#

  dropdown: ->
    if @props.isLocked
      null
    else if @props.documentType == 'Policy'
      # `<div className="wt-dropdown">
      #   <i className="icon-down"></i>
      #   <ul className="wt-dropdown__block">
      #     <li><a onClick={function() { this.props.openAddRenewalModal(this.props.document)}.bind(this) }>Add Renewal</a></li>
      #   </ul>
      # </div>`
    else if @props.documentType == 'Proposal'
      `<div className="wt-dropdown">
        <i className="icon-down"></i>
        <ul className="wt-dropdown__block">
          <li><a onClick={this._archiveProject}>Archive this proposal</a></li>
          <li><a onClick={this._selectAsSold}>Select as sold plan</a></li>
        </ul>
      </div>`

  render: ->
    classes = React.addons.classSet(
      'wt-headercell'         : true
      'wt-headercell--column' : true
      'wt-headercell--sticky' : @props.isPolicy
      'wt-headercell--hidden' : !@props.isVisible
    )

    leftClasses = React.addons.classSet(
      'wt-headercell__sort'           : true
      'wt-headercell__sort--left'     : true
      'wt-headercell__sort--disabled' : !@props.canMoveLeft
    )

    rightClasses = React.addons.classSet(
      'wt-headercell__sort'           : true
      'wt-headercell__sort--right'    : true
      'wt-headercell__sort--disabled' : !@props.canMoveRight
    )

    if @props.isVisible
      leftSortButton = (
        `<div className={leftClasses} onClick={this._moveColumnLeft}>
          <i className="icon-right"></i>
        </div>`
      ) unless @props.isPolicy
      rightSortButton = (
        `<div className={rightClasses} onClick={this._moveColumnRight}>
          <i className="icon-right"></i>
        </div>`
      ) unless @props.isPolicy
      headerInfo = (
        `<div>
          <small>{this.props.filenames[0]}</small>
          <img src={this.props.carrierLogo} title={this.props.carrierName} />
          {leftSortButton}
          {rightSortButton}
        </div>`
      )
      dropdown = this.dropdown()
    else
      headerInfo = (
        `<div>
          <small>{this.props.filenames[0]}</small>
          <h6 className="h6">Analyzing<br />Uploaded Document(s)</h6>
          <small><em>Data should be available<br />approximately 24 hours after upload</em></small>
        </div>`
      )

    return (
      `<div className={classes}>
        {headerInfo}
        {dropdown}
      </div>`
    )

#-----------  Export  -----------#

module.exports = ColumnHeader

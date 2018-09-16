#-----------  Requirements  -----------#

DataTableActions = require('actions/data_table')
PureRenderMixin  = require('react-addons-pure-render-mixin')
groupClassNumbers = require('utils/utility_functions').groupClassNumbers

#-----------  React Componet Class  -----------#

SidebarCell = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    rowID             : React.PropTypes.number
    value             : React.PropTypes.string.isRequired
    isGrouping        : React.PropTypes.bool
    isCollapsed       : React.PropTypes.bool
    showClassNumbers  : React.PropTypes.bool
    showAttributeName : React.PropTypes.bool
    classNumbers      : React.PropTypes.arrayOf(React.PropTypes.number)
    hasContextual     : React.PropTypes.bool
    openContextualContentModal: React.PropTypes.func

  getDefaultProps: ->
    return {
      rowID             : null
      isCollapsed       : false
      hasContextual     : false
      isGrouping        : false
      showAttributeName : true
    }

  #-----------  Event Handlers  -----------#

  _onCellClick: (evt) ->
    DataTableActions.toggleRowCollapse(@props.rowID, @props.classNumbers[0], !@props.isCollapsed) unless @props.isGrouping

  _onClickContextualIcon: (evt) ->
    evt.stopPropagation()
    @props.openContextualContentModal(@props.rowID, @props.value)
    false

  #-----------  HTML Element Render  -----------#

  render: ->
    showClassNumbers = !@props.isGrouping && @props.showClassNumbers && @props.classNumbers
    classes = React.addons.classSet(
      'wt-tablecell'            : true
      'wt-tablecell--sidebar'   : true
      'wt-tablecell--collapsed' : @props.isCollapsed
      'wt-tablecell--grouping'  : @props.isGrouping
      'wt-tablecell--contextual'  : @props.hasContextual
    )
    attributeName = ''
    attributeName = @props.value if @props.showAttributeName
    classNumbers = ''
    if showClassNumbers
      classNumbers = groupClassNumbers(@props.classNumbers)
    contextualIcon = ''
    if @props.hasContextual
      contextualIcon = `<a href="#" className="wt-tablecell--contextual-icon" onClick={this._onClickContextualIcon}></a>`
    return (
      `<div className={classes} onClick={this._onCellClick}>
        <div className="wt-tablecell__value wt-tablecell__attribute">
          {attributeName}
          {contextualIcon}
        </div>
        <span className="wt-tablecell__value wt-tablecell__class_names" >{classNumbers}</span>
      </div>`
    )

#-----------  Export  -----------#

module.exports = SidebarCell

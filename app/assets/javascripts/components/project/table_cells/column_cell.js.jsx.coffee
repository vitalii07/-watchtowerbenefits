#-----------  Requirements  -----------#

DataTableActions = require('actions/data_table')
PureRenderMixin  = require('react-addons-pure-render-mixin')

#-----------  React Componet Class  -----------#

ColumnCell = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    value         : React.PropTypes.any
    columnID      : React.PropTypes.number.isRequired
    attributeID   : React.PropTypes.number
    classNumber   : React.PropTypes.number
    discrepency   : React.PropTypes.string
    isGrouping    : React.PropTypes.bool
    isCollapsed   : React.PropTypes.bool
    isVisible     : React.PropTypes.bool
    isPolicy      : React.PropTypes.bool
    isClassQuoted : React.PropTypes.bool
    isDescAttr    : React.PropTypes.bool

  getDefaultProps: ->
    return {
      value         : null
      attributeID   : null
      classNumber   : null
      isCollapsed   : false
      isGrouping    : false
      isVisible     : false
      isPolicy      : false
      isClassQuoted : true
      isDescAttr    : false
    }

  getInitialState: ->
    return { flag: @props.discrepency }

  #-----------  Event Handlers  -----------#

  _discrepencies: ['neutral', 'positive', 'negative', '']

  _onCellClick: (evt) ->
    has_discrepency = _.indexOf(@_discrepencies, @state.flag)

    if @props.attributeID && !@props.isCollapsed && !@props.isPolicy
      length = @_discrepencies.length
      next = @_discrepencies[(has_discrepency+1)%length]

      DataTableActions.toggleAttributelDiscrepency(@props.attributeID, @props.columnID, next, @props.classNumber)
      @setState({ flag: next })

  #-----------  HTML Element Render  -----------#

  _isUnstated: ->
    # TODO: umm...clarify what an unstated attribute should actually be
    return !@props.attributeID || !@props.value || @props.value == '' || @props.value == 'Unstated' || @props.value == 'unstated'

  render: ->
    classes = React.addons.classSet(
      'wt-tablecell'            : true
      'wt-tablecell--column'    : true
      'wt-tablecell--grouping'  : @props.isGrouping
      'wt-tablecell--collapsed' : @props.isCollapsed
      'wt-tablecell--sticky'    : @props.isPolicy
      'wt-tablecell--neutral'   : @state.flag == 'neutral'
      'wt-tablecell--positive'  : @state.flag == 'positive'
      'wt-tablecell--negative'  : @state.flag == 'negative'
      'wt-tablecell--unstated'  : @_isUnstated() && !@props.isGrouping && @props.isVisible
      'wt-tablecell--hidden'    : !@props.isVisible
    )

    unless @props.isVisible
      return (`<div className={classes}></div>`)

    if @props.isGrouping
      display = ''
    else if !@props.isClassQuoted && @props.isDescAttr
      display = 'Class Not Included'
    else if @_isUnstated()
      display = 'Unstated'
    else # is an age-banded rate
      flag = `<div className="wt-tablecell__discrepency-flag"></div>`
      if _.isObject(@props.value)
        display = []

        sortedKeys = _.keys(@props.value).sort()

        _.each sortedKeys, (title) =>
          value = @props.value[title]
          key = [title, value].join('')
          title_display = title.replace(/_/g, ' ')
          display.push(
            `<div className="wt-tablecell__cell-row" key={key}>
              <span className="wt-tablecell__cell-row--title">{title_display}</span>
              <span className="wt-tablecell__cell-row--value">{value}</span>
            </div>`
          )
      else
        display = @props.value

    return (
      `<div className={classes} onClick={this._onCellClick}>
        {flag}
        <span className="wt-tablecell__value">{display}</span>
      </div>`
    )

#-----------  Export  -----------#

module.exports = ColumnCell

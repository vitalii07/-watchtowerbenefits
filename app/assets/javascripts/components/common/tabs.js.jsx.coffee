#-----------  React Componet Class  -----------#

Tabs = React.createClass

  propTypes:
    tabActive      : React.PropTypes.number
    onMount        : React.PropTypes.func
    onBeforeChange : React.PropTypes.func
    onAfterChange  : React.PropTypes.func
    children       : React.PropTypes.oneOfType([
      React.PropTypes.array
      React.PropTypes.element
    ]).isRequired

  getDefaultProps: ->
    return {
      tabActive: 1
    }

  getInitialState: ->
    return {
      tabActive: @props.tabActive
    }

  #-----------  HTML Element Render  -----------#

  componentDidMount: ->
    index          = @state.tabActive
    selected_panel = @refs['tab-panel']
    selected_menu  = @refs["tab-menu-#{index}"]

    $(window).on 'distillery:activateTab', @_manualSetActive

    if @props.onMount
      @props.onMount(index, selected_panel, selected_menu)

    @props.onAfterChange(index) if @props.onAfterChange

  componentWillUpdate: ->
    @props.onBeforeChange() if @props.onBeforeChange

  componentDidUpdate: (prevProps, prevState) ->
    @props.onAfterChange(@state.tabActive) if @props.onAfterChange

  #-----------  Event Handlers  -----------#
  _manualSetActive: (event, index) ->
    @_setActive(index, event)

  _setActive: (index, evt) ->
    evt.preventDefault() if evt.preventDefault
    @setState({tabActive: index})

  #-----------  HTML Element Render  -----------#

  render: ->
    if !@props.children
      throw new Error('Tabs must contain at least one Tabs.Panel')

    if !Array.isArray(@props.children)
      @props.children = [@props.children]

    component = @
    current_index = @state.tabActive

    menu_items = @props.children.map (panel, index) ->
      ref = "tab-menu-#{index + 1}"
      classes = React.addons.classSet(
        'wt-tabs__menu-item'         : true
        'wt-tabs__menu-item--active' : current_index == (index + 1)
      )
      return (
        `<div ref={ref} key={ref} className={classes}>
          <a onClick={component._setActive.bind(component, index + 1)}>
            {panel.props.title}
          </a>
        </div>`
      )

    panel_items = @props.children.map (panel, index) ->
      ref = "tab-panel-#{index + 1}"
      classes = React.addons.classSet(
        'wt-tabs__panel'         : true
        'wt-tabs__panel--active' : current_index == (index + 1)
      )
      return (
        `<div ref={ref} key={ref} className={classes}>
          {panel}
        </div>`
      )

    return (
      `<div className='wt-tabs'>
        <nav className='wt-tabs__navigation'>
          {menu_items}
        </nav>
        {panel_items}
      </div>`
    )

#-----------  React Componet Class  -----------#

Tabs.Panel = React.createClass

  propTypes:
    title    : React.PropTypes.string.isRequired
    children : React.PropTypes.oneOfType([
      React.PropTypes.array
      React.PropTypes.element
    ]).isRequired

  render: ->
    return `<div>{this.props.children}</div>`

#-----------  Export  -----------#

module.exports = Tabs

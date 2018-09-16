#-----------  Requirements  -----------#

Tabs = require('components/common/tabs')

#-----------  React Componet Class  -----------#

TabbedSources = React.createClass

  propTypes:
    sources: React.PropTypes.array.isRequired

  #-----------  Sizing / Scrolling Helpers  -----------#

  componentDidMount: ->
    $(window).on 'resize sidebar:toggle', @_setActive

  #-----------  Event Handlers  -----------#

  _activateTab: (activeTabIndex) ->
    window.distillery.setActiveTabIndex(activeTabIndex - 1)
    @_updateSizing()

  _updateSizing: ->
    elem = $(React.findDOMNode(@))
    $('iframe').height(elem.height()).width(elem.width())

  #-----------  HTML Element Render  -----------#

  render: ->
    tab_panels = []

    for src, i in @props.sources
      title = "Source #{i+1}"
      tab_panels.push(
        `<Tabs.Panel title={title} key={title}>
          <iframe src={src} className='document_content'></iframe>
        </Tabs.Panel>`
      )

    return (
      `<Tabs onAfterChange={this._activateTab}>
        {tab_panels}
      </Tabs>`
    )

#-----------  Export  -----------#

module.exports = TabbedSources
window.TabbedSources = TabbedSources

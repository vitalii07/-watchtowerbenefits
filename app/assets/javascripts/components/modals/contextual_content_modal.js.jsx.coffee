Modal = require('components/common/modal')
Markdown = require('components/common/markdown')
DataTableStore = require('stores/data_table')

ContextualContentModal = React.createClass
  propTypes:
    open: React.PropTypes.bool.isRequired
    attributeId: React.PropTypes.number
    attributeName: React.PropTypes.string
    closeModal: React.PropTypes.func

  getInitialState: ->
    primaryContents: []
    secondaryContents: []
    secondaryIndex: -1

  componentWillReceiveProps: (new_props) ->
    content = DataTableStore.getContextualContents(new_props.attributeId)
    if content
      @setState(
        primaryContents: content.primary || []
        secondaryContents: content.secondary || []
        secondaryIndex: -1
      )

  toggleSecondary: (index, event) ->
    event.preventDefault()
    @setState(secondaryIndex: index)

  render: ->
    primaryContents = []
    for item, index in @state.primaryContents
      primaryContents.push(
        `<div>
          <u>{item.title}: </u>
          <Markdown source={item.content}/>
        </div>`
      )
    secondaryItems = []
    for item, index in @state.secondaryContents
      secondaryItems.push(
        `<li><a href="#" onClick={this.toggleSecondary.bind(this, index)}>{item.title}</a></li>`
      )
      if index == @state.secondaryIndex
        secondaryItems.push(
          `<li><Markdown source={item.content}/></li>`
        )
    if secondaryItems.length > 0
      secondaryContents = (
        `<div className="wt-contextual__secondary">
          <hr/>
          <div>Learn More:</div>
          <ul>
            {secondaryItems}
          </ul>
        </div>`
      )


    `<Modal title={this.props.attributeName} wtModalBlockStyle={{maxWidth: '450px', textAlign: 'center'}}
      isOpen={this.props.open}
      closeModalCallback={this.props.closeModal} >
      <div className="wt-contextual-content">
        {primaryContents}
        {secondaryContents}
      </div>
    </Modal>`

module.exports = ContextualContentModal

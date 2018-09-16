#-----------  Requirements  -----------#

DataTableActions = require('actions/data_table')
ToggleSwitch     = require('components/common/toggle_switch')
PureRenderMixin  = require('react-addons-pure-render-mixin')

#-----------  React Componet Class  -----------#

SidebarHeader = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    products            : React.PropTypes.object.isRequired
    currentProduct      : React.PropTypes.string.isRequired
    currentClass        : React.PropTypes.string.isRequired
    showAdvanced        : React.PropTypes.bool
    showIgnoreAttributes: React.PropTypes.bool
    rollupClasses       : React.PropTypes.bool

  getDefaultProps: ->
    return { showAdvanced: true, showIgnoreAttributes: false, rollupClasses: true }

  #-----------  Event Handlers  -----------#

  _onProductSelection: (evt) ->
    selectedProduct       = evt.target.value
    selectedClass         = _.keys(@props.products[selectedProduct].product_classes)[0]
    showAdvanced          = null
    showIgnoreAttributes  = null

    DataTableActions.changeFilters(selectedProduct, selectedClass, showAdvanced, showIgnoreAttributes)

  _onClassSelection: (evt) ->
    selectedProduct       = @props.currentProduct
    selectedClass         = evt.target.value
    showAdvanced          = @props.showAdvanced
    showIgnoreAttributes  = @props.showIgnoreAttributes

    DataTableActions.changeFilters(selectedProduct, selectedClass, showAdvanced, showIgnoreAttributes)

  _onAdvancedToggle: (evt) ->
    selectedProduct       = @props.currentProduct
    selectedClass         = @props.currentClass
    showAdvanced          = !@props.showAdvanced
    showIgnoreAttributes  = @props.showIgnoreAttributes

    DataTableActions.changeFilters(selectedProduct, selectedClass, showAdvanced, showIgnoreAttributes)

  _onIgnoreToggle: (evt) ->
    selectedProduct       = @props.currentProduct
    selectedClass         = @props.currentClass
    showAdvanced          = @props.showAdvanced
    showIgnoreAttributes  = !@props.showIgnoreAttributes

    DataTableActions.changeFilters(selectedProduct, selectedClass, showAdvanced, showIgnoreAttributes)

  #-----------  HTML Element Render  -----------#

  render: ->
    classes = React.addons.classSet(
      'wt-headercell'          : true
      'wt-headercell--sidebar' : true
    )

    productOptions = []
    headerContents = []

    for product in @props.orderedProducts
      is_disabled = product.is_empty
      productOptions.push `<option value={product.product_id} key={product.product_id} disabled={is_disabled}>{product.name}</option>`

    headerContents.push(
      `
        <div className="select-wrapper">
          <select
            value={this.props.currentProduct}
            onChange={this._onProductSelection}
          >
            {productOptions}
          </select>
        </div>
      `
    )

    unless @props.rollupClasses
      classOptions = []
      for klass_id, klass of @props.products[@props.currentProduct].product_classes
        is_disabled = klass.is_empty
        classOptions.push `<option value={klass_id} key={klass_id} disabled={is_disabled}>{klass.name}</option>`
      headerContents.push(
        `<div className="select-wrapper">
           <select
             value={this.props.currentClass}
             onChange={this._onClassSelection}
           >
             {classOptions}
           </select>
         </div>`
      )
    headerContents.push(
      `<div className="wt-headercell--headers">
        <span className="wt-headercell--attribute"></span>
        <span className="wt-headercell--class-names">Class</span>
      </div>`
    )

    return (
      `<div className={classes}>
        {headerContents}
      </div>`
    )

#-----------  Export  -----------#

module.exports = SidebarHeader

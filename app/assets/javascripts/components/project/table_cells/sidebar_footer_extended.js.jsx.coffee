#-----------  Requirements  -----------#

DataTableActions = require('actions/data_table')
PureRenderMixin  = require('react-addons-pure-render-mixin')

#-----------  React Componet Class  -----------#

SidebarFooterExtended = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    products          : React.PropTypes.array.isRequired
    rateDenominators  : React.PropTypes.object.isRequired
    onFooterExpansion : React.PropTypes.func.isRequired

  #-----------  Event Handlers  -----------#

  _onVolumeChange: (evt) ->
    DataTableActions.changeProductVolume(evt.target.value)

  #-----------  HTML Element Render  -----------#

  render: ->
    classes = React.addons.classSet(
      'wt-footercell'           : true
      'wt-footercell--sidebar'  : true
      'wt-footercell--expanded' : true
    )

    #-----------  Product Content  -----------#

    productRows = []

    for product in @props.products
      product_id = product.product_id
      key        = "sidebar-product-row-#{product_id}"

      if @props.rateDenominators[product_id]
        value = @props.rateDenominators[product_id]
        denomination = `<small>/${value}</small>`
      else
        denomination = `<small></small>`

      productRows.push(
        `<div className="wt-footercell__content" key={key}>
          <div className="wt-footercell__data-row">
            <div className="wt-footercell__product-name">{product.name}</div>
            {denomination}
          </div>
        </div>`
      )

    #-----------  Final Output  -----------#

    return (
      `<div className={classes}>
        <div className="wt-footercell__header">
          <div className="wt-footercell__data-row">
            <div className="wt-footercell__title">Total Cost Analysis</div>
            <small>/yr</small>
          </div>
        </div>

        {productRows}

        <div className="wt-footercell__footer">
          <div className="wt-footercell__expand-button" onClick={this.props.onFooterExpansion}>
            Hide Total Costs
            <i className="icon-down"></i>
          </div>
        </div>
      </div>`
    )

#-----------  Export  -----------#

module.exports = SidebarFooterExtended

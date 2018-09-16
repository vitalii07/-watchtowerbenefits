#-----------  Requirements  -----------#

isUsableNumber   = require('utils/utility_functions').isUsableNumber
currencyFormater = require('utils/utility_functions').currencyFormater
PureRenderMixin  = require('react-addons-pure-render-mixin')

#-----------  React Componet Class  -----------#

ColumnFooterExtended = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    column           : React.PropTypes.number.isRequired
    products         : React.PropTypes.array.isRequired
    unitRates        : React.PropTypes.object.isRequired
    rateDenominators : React.PropTypes.object.isRequired
    rateGuarantees   : React.PropTypes.object.isRequired
    contributoryData : React.PropTypes.object.isRequired
    premiumValues    : React.PropTypes.object.isRequired
    comparisonValues : React.PropTypes.any.isRequired
    isVisible        : React.PropTypes.bool
    isPolicy         : React.PropTypes.bool
    hasVolume        : React.PropTypes.object.isRequired

  getDefaultProps: ->
    return {
      isVisible : false
      isPolicy  : false
    }

  #-----------  HTML Element Render  -----------#

  render: ->
    classes = React.addons.classSet(
      'wt-footercell'           : true
      'wt-footercell--column'   : true
      'wt-footercell--expanded' : true
      'wt-footercell--sticky'   : @props.isPolicy
      'wt-footercell--hidden'   : !@props.isVisible
    )

    unless @props.isVisible
      return (`<div className={classes}></div>`)

    total_cost = 0
    has_comparison_rates = !_.isEmpty(@props.comparisonValues)

    #-----------  Product Content  -----------#

    productRows = []

    for index, product of @props.products
      yearly_total = 0
      product_id   = product.product_id
      key          = "#{@props.column}-product-row-#{product_id}"

      is_contributory   = @props.contributoryData[product_id]
      unit_rate         = @props.unitRates[product_id]
      rate_denomination = parseInt(@props.rateDenominators[product_id])
      premiumValue      = @props.premiumValues[product_id]
      rate_guarantee    = @props.rateGuarantees[product_id]
      has_volume        = @props.hasVolume[product_id]

      if @props.contributoryData[product_id] == true
        productRows.push(
          `<div className="wt-footercell__content" key={key}>
            <div className="wt-footercell__data-row">
              <em>contributory product</em>
            </div>
          </div>`
        )
      else if !isUsableNumber(unit_rate)
        productRows.push(
          `<div className="wt-footercell__content" key={key}>
            <div className="wt-footercell__data-row">
              <em>no rate provided</em>
            </div>
          </div>`
        )
      else if has_volume && isUsableNumber(premiumValue)
        yearly_total = premiumValue * 12
        yearly_display = currencyFormater(yearly_total)

        productRows.push(
          `<div className="wt-footercell__content" key={key}>
            <div className="wt-footercell__data-row">
              ${unit_rate.toFixed(3)} / {rate_guarantee} mo
              <div>{yearly_display}</div>
            </div>
          </div>`
        )
      else
        productRows.push(
          `<div className="wt-footercell__content" key={key}>
            <div className="wt-footercell__data-row">
              ${unit_rate.toFixed(3)} / {rate_guarantee} mo
              <div><em>volume not entered yet</em></div>
            </div>
          </div>`
        )
      total_cost = total_cost + yearly_total

    #-----------  Footer Content  -----------#

    if @props.isPolicy
      cellFooter = (
        `<div className="wt-footercell__footer">
          <div className="wt-footercell__data-row">
            Current Policy
            <small><i className="icon-lock"></i></small>
          </div>
        </div>`
      )
    else if !has_comparison_rates
      cellFooter = `<div className="wt-footercell__footer"></div>`
    else if total_cost
      comparison_total = 0

      for index, product of @props.products
        comparison_value = @props.comparisonValues[product.product_id]
        comparison_total = comparison_total + comparison_value * 12 if isUsableNumber(comparison_value)

      difference_percentage = (((total_cost - comparison_total) / comparison_total) * 100)
      difference_value      = currencyFormater(total_cost - comparison_total)
      difference_symbol     = if (difference_percentage > 0) then '+' else ''
      difference_color      = if (difference_percentage > 0) then 'red' else 'green'
      difference_class      = "wt-footercell__footer wt-footercell__footer--#{difference_color}"

      cellFooter = (
        `<div className={difference_class}>
          <div className="wt-footercell__data-row">
            {difference_symbol}{difference_percentage.toFixed(1)}% &nbsp; &nbsp; {difference_symbol}{difference_value}
            <small>/yr</small>
          </div>
        </div>`
      )
    else
      cellFooter = (
        `<div className="wt-footercell__footer">
          <div className="wt-footercell__data-row">
            0% &nbsp; &nbsp; $0
            <small>/yr</small>
          </div>
        </div>`
      )

    #-----------  Final Output  -----------#

    header_total = currencyFormater(total_cost)

    return (
      `<div className={classes}>
        <div className="wt-footercell__header">
          <div className="wt-footercell__data-row">
            {header_total}
          </div>
        </div>

        {productRows}

        {cellFooter}
      </div>`
    )

#-----------  Export  -----------#

module.exports = ColumnFooterExtended

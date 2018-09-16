#-----------  Requirements  -----------#

isUsableNumber   = require('utils/utility_functions').isUsableNumber
currencyFormater = require('utils/utility_functions').currencyFormater
PureRenderMixin  = require('react-addons-pure-render-mixin')

#-----------  React Componet Class  -----------#

ColumnFooter = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    unitRate        : React.PropTypes.number
    rateDenominator : React.PropTypes.number
    rateGuarantee   : React.PropTypes.any
    premiumValue    : React.PropTypes.string
    comparisonValue : React.PropTypes.number
    isContributory  : React.PropTypes.bool
    isCompact       : React.PropTypes.bool
    isVisible       : React.PropTypes.bool
    isPolicy        : React.PropTypes.bool
    hasVolume       : React.PropTypes.bool

  getDefaultProps: ->
    return {
      unitRate        : 0
      rateDenominator : null
      rateGuarantee   : 0
      premiumValue    : 0
      comparisonValue : 0
      isContributory  : null
      isCompact       : true
      isVisible       : false
      isPolicy        : false
      hasVolume       : false
    }

  _openRateVolumeModal: ->
    this.props.openRateVolumeModal(
      this.props.productId,
      this.props.documentId
    )

  #-----------  HTML Element Render  -----------#

  render: ->
    classes = React.addons.classSet(
      'wt-footercell'               : true
      'wt-footercell--column'       : true
      'wt-footercell--sticky'       : @props.isPolicy
      'wt-footercell--contributory' : @props.isContributory
      'wt-footercell--compact'      : @props.isCompact
      'wt-footercell--hidden'       : !@props.isVisible
    )

    #-----------  Quick Defaults  -----------#

    if !@props.isVisible
      return (`<div className={classes}></div>`)

    if @props.isCompact
      if @props.isPolicy
        cellFooter = (
          `<div className="wt-footercell__footer">
            <div className="wt-footercell__data-row">
              Current Policy
              <small><i className="icon-lock"></i></small>
            </div>
          </div>`
        )
      else
        cellFooter = (
          `<div className="wt-footercell__footer">
          </div>`
        )
      return (`<div className={classes}>{cellFooter}</div>`)

    unit_rate         = parseFloat(@props.unitRate)

    #-----------  Main Content  -----------#
    unitContent = null
    monthlyContent = null
    yearlyContent = null
    cellFooter = null

    if isUsableNumber(unit_rate)
      unitContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            ${unit_rate.toFixed(3)} / {this.props.rateGuarantee} mo
            <small>/${this.props.rateDenominator}</small>
          </div>
          <a onClick={this._openRateVolumeModal} className="wt-footercell__volume-edit">Edit</a>
        </div>`
      )

    if @props.isContributory == true
      unitContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <div><em>contributory product</em></div>
          </div>
        </div>`
      )
    else if !isUsableNumber(unit_rate)
      monthlyContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <div><em>no rate provided</em></div>
          </div>
        </div>`
      )
      yearlyContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <div><em>no rate provided</em></div>
          </div>
        </div>`
      )
    else if @props.hasVolume && isUsableNumber(@props.premiumValue)
      monthlyContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <div>{currencyFormater(this.props.premiumValue)}</div>
            <small>/mo</small>
          </div>
        </div>`
      )
      yearlyContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <div>{currencyFormater(this.props.premiumValue * 12)}</div>
            <small>/yr</small>
          </div>
        </div>`
      )
    else
      monthlyContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <a onClick={this._openRateVolumeModal}>Class-mismatch. Edit Volume</a>
          </div>
        </div>`
      )
      yearlyContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <a onClick={this._openRateVolumeModal}>Class-mismatch. Edit Volume</a>
          </div>
        </div>`
      )

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
    else if @props.isContributory
      cellFooter = (
        `<div className="wt-footercell__footer">
          &nbsp;
        </div>`
      )
    else if isUsableNumber(@props.premiumValue) && isUsableNumber(@props.comparisonValue)
      comparison_rate       = (@props.premiumValue - @props.comparisonValue) / @props.comparisonValue
      difference_percentage = comparison_rate * 100
      difference_value      = currencyFormater((@props.premiumValue - @props.comparisonValue) * 12)
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
    return (
      `<div className={classes}>
        {unitContent}
        {monthlyContent}
        {yearlyContent}
        {cellFooter}
      </div>`
    )

#-----------  Export  -----------#

module.exports = ColumnFooter

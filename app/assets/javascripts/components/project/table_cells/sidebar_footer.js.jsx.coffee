#-----------  Requirements  -----------#

DataTableActions = require('actions/data_table')
PureRenderMixin  = require('react-addons-pure-render-mixin')

#-----------  React Componet Class  -----------#

SidebarFooter = React.createClass

  mixins: [PureRenderMixin]

  propTypes:
    productId         : React.PropTypes.number
    documentId        : React.PropTypes.number
    isContributory    : React.PropTypes.bool
    onFooterExpansion : React.PropTypes.func
    openRateVolumeModal : React.PropTypes.func

  _openRateVolumeModal: ->
    this.props.openRateVolumeModal(
      this.props.productId,
      this.props.documentId
    )

  #-----------  HTML Element Render  -----------#

  render: ->
    classes = React.addons.classSet(
      'wt-footercell'               : true
      'wt-footercell--sidebar'      : true
      'wt-footercell--contributory' : @props.isContributory
    )

    #-----------  Main Content  -----------#

    if @props.isContributory
      cellContent = (
        `<div className="wt-footercell__content">
          <div className="wt-footercell__data-row">
            <div className="wt-footercell__title">Product Cost Analysis</div>
            <button onClick={this._openRateVolumeModal}>Enter Volume</button>
          </div>
        </div>`
      )
    else
      cellContent = ''

    #-----------  Footer Content  -----------#

    if @props.isContributory
      cellFooter = (
        `<div className="wt-footercell__footer">
          <div className="wt-footercell__expand-button" onClick={this.props.onFooterExpansion}>
            View Total Costs
            <i className="icon-up"></i>
          </div>
        </div>`
      )
    else
      cellFooter = ''

    #-----------  Final Output  -----------#

    return (
      `<div className={classes}>
        {cellContent}
        {cellFooter}
      </div>`
    )

#-----------  Export  -----------#

module.exports = SidebarFooter

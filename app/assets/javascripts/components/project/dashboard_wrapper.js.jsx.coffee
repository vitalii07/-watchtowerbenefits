#-----------  Requirements  -----------#

DataTable = require('components/project/data_table')
AddRenewalModal = require('components/modals/add_renewal_modal')
ContextualContentModal = require('components/modals/contextual_content_modal')
RateVolumeModal = require('components/modals/rate_volume_modal')

#-----------  React Componet Class  -----------#

DashboardWrapper = React.createClass

  getInitialState: ->
    return {
      renderPage  : false
      tableWidth  : 500
      tableHeight : 500
      addRenewalModal: {open: false, document: {products: []}}
      contextualContentModal: {open: false, attributeId: null, attributeName: null}
      rateVolumeModal: {open: false, documentId: null, productId: null}
    }

  componentDidMount: ->
    @_updateSizing()
    @_addResizeListeners()

  openAddRenewalModal: (document) ->
    @setState({addRenewalModal: {open: true, document: document}})

  openContextualContentModal: (attributeId, attributeName) ->
    @setState({contextualContentModal: {open: true, attributeId: attributeId, attributeName: attributeName}})

  openRateVolumeModal: (productId, documentId) ->
    @setState({rateVolumeModal: {open: true, documentId: documentId, productId: productId}})

  closeAddRenewalModal: ->
    @setState({addRenewalModal: @getInitialState().addRenewalModal})

  closeContextualContentModal: ->
    @setState({contextualContentModal: @getInitialState().contextualContentModal})

  closeRateVolumeModal: ->
    @setState({rateVolumeModal: @getInitialState().rateVolumeModal})

  #-----------  Sizing / Scrolling Helpers  -----------#

  _addResizeListeners: ->
    $(window).on 'resize sidebar:toggle', @_onResize

  _onResize: ->
    clearTimeout(@_updateTimer)
    @_updateTimer = setTimeout(@_updateSizing, 16)

  _updateSizing: ->
    @setState({
      renderPage  : true
      tableWidth  : $('.wt-page-content__main').width()
      tableHeight : $('.wt-page-content__main').height()
    })

  #-----------  HTML Element Render  -----------#

  render: ->
    return `<div>
      <AddRenewalModal
        open={this.state.addRenewalModal.open}
        document={this.state.addRenewalModal.document}
        closeModal={this.closeAddRenewalModal} />
      <ContextualContentModal
        open={this.state.contextualContentModal.open}
        attributeId={this.state.contextualContentModal.attributeId}
        attributeName={this.state.contextualContentModal.attributeName}
        closeModal={this.closeContextualContentModal} />
      <RateVolumeModal
        open={this.state.rateVolumeModal.open}
        productId={this.state.rateVolumeModal.productId}
        documentId={this.state.rateVolumeModal.documentId}
        closeModal={this.closeRateVolumeModal} />
      <DataTable {...this.state}
        openAddRenewalModal={this.openAddRenewalModal}
        openContextualContentModal={this.openContextualContentModal}
        openRateVolumeModal={this.openRateVolumeModal} />
    </div>`

#-----------  Export  -----------#

module.exports = DashboardWrapper
window.DashboardWrapper = DashboardWrapper

Modal = require('components/common/modal')
DataTableActions = require('actions/data_table')
rateValues = require('components/modals/add_renewal_modal/helpers').rateValues
ProductRow = require('components/modals/add_renewal_modal/product_row')
AGE_BAND_LABELS = require('components/modals/add_renewal_modal/value_row_compound').AGE_BAND_LABELS
COMPOSITE_LABELS = require('components/modals/add_renewal_modal/value_row_compound').COMPOSITE_LABELS

AddRenewalModal = React.createClass
  propTypes:
    open: React.PropTypes.bool.isRequired
    document: React.PropTypes.object
    closeModal: React.PropTypes.func

  getInitialState: ->
    return {values_lib: {}, request_sent: false}

  componentWillReceiveProps: (new_props) ->
    if Object.keys(@state.values_lib).length == 0
      update_query = {values_lib: {}}
      new_props.document.products.forEach(((p) ->
        update_query[p.id] = {}
        values = _.flatten(p.product_classes.map(((pc) -> rateValues(pc)).bind(this)))
        values.forEach(((value) ->
          update_query.values_lib[value.id] = value
          update_query[p.id][value.id] = undefined
        ).bind(this))
      ).bind(this))
      @setState(update_query)

  updateInputValue: (product, key, val) ->
    value_query = {}
    value_query[key] = {$set: val}
    update_query = {}
    update_query[product.id] = React.addons.update(@state[product.id], value_query)
    @setState(update_query)

  applyToAllClasses: (product) ->
    value_ids = _.filter(Object.keys(@state[product.id]), (value_id) -> parseInt(value_id) > 0)
    values = _.map(value_ids, ((value_id) -> @state.values_lib[value_id]).bind(this))
    new_state = Object.assign({}, @state[product.id])
    values.forEach(((value) ->
      new_state[value.id] = @state[product.id]['Rate'] if value.name != 'Rate Guarantee'
    ).bind(this))
    update_query = {}
    update_query[product.id] = new_state
    @setState(update_query)

  assignRateGuarantee: (input_values) ->
    values = Object.assign({}, input_values)
    Object.keys(values).forEach(((id) ->
      if @state.values_lib[id] && @state.values_lib[id].name == 'Rate Guarantee'
        values[id] = values['Rate Guarantee']
    ).bind(this))
    values

  removeStringKeysAndBlankValues: (input_values) ->
    values = Object.assign({}, input_values)
    Object.keys(values).forEach((key) -> delete values[key] if !(parseInt(key) > 0) || !values[key])
    values

  filterCompoundValue: (value) ->
    if value.type == 'Age Banded'
      delete value.composite
    else if value.type == 'Composite'
      _.each(AGE_BAND_LABELS, (label) -> delete value[label])
    _.each(Object.keys(value), (key) -> delete value[key] if value[key] == '' || !value[key])

  collectProductValues: (product) ->
    values = @assignRateGuarantee(@state[product.id])
    values = @removeStringKeysAndBlankValues(values)
    compoundValues = _.filter(_.values(values), (v) -> _.isObject(v))
    _.forEach(compoundValues, @filterCompoundValue)
    values

  collectValuesForSending: ->
    values = {}
    @props.document.products.forEach(((product) ->
      Object.assign(values, @collectProductValues(product))
    ).bind(this))
    values

  createRenewalOffer: ->
    @setState({request_sent: true})
    DataTableActions.createRenewalProposal(@props.document.id, @collectValuesForSending())

  productRow: (product) ->
    return `<ProductRow
      key={product.id}
      product={product}
      updateInputValue={this.updateInputValue}
      valuesLibrary={this.state}
      applyToAllClasses={this.applyToAllClasses} />
    `

  buttonLabel: () ->
    if this.state.request_sent then `<div >loading...</div>` else 'CREATE RENEWAL OFFER'

  render: ->
    products = _.sortBy(_.sortBy(this.props.document.products, 'name'), 'product_position')
    return `<Modal title="Create Renewal Offer" wtModalBlockStyle={{maxWidth: '600px'}}
      isOpen={this.props.open}
      closeModalCallback={this.props.closeModal} >
      <div className='_renewal__products-container'>
        {products.map(function(product) { return this.productRow(product) }.bind(this) )}
      </div>
      <button onClick={this.createRenewalOffer}>{this.buttonLabel()}</button>
    </Modal>`

module.exports = AddRenewalModal

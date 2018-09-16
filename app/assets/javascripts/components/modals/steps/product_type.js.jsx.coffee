#-----------  React Componet Class  -----------#

ProductType = React.createClass

  propTypes:
    index                 : React.PropTypes.any.isRequired
    availableProductTypes : React.PropTypes.array.isRequired
    selectedTypes         : React.PropTypes.array.isRequired
    productTypeID         : React.PropTypes.any
    isInforce             : React.PropTypes.bool
    removeProduct         : React.PropTypes.func.isRequired
    saveProduct           : React.PropTypes.func.isRequired

  getDefaultProps: ->
    return { isInforce: false }

  getInitialState: ->
    return {
      productTypeID : @props.productTypeID || 0
      isInforce     : @props.isInforce || false
    }

  #-----------  Event Handlers  -----------#

  _onChange: (evt) ->
    inforce = @refs.product_is_inforce.getDOMNode().checked
    product_id = @refs.product_type_id.getDOMNode().value

    @setState {
      productTypeID : product_id
      isInforce     : inforce
    }

    @props.saveProduct {
      index           : @props.index
      inforce         : inforce
      product_type_id : product_id
      model_id        : @props.model_id
    }

  _removeProduct: (evt) ->
    @props.removeProduct(@props.index)

  #-----------  HTML Element Render  -----------#

  render: ->
    productTypeOptions = []
    new_product = _.isEmpty(this.state.productTypeID)

    for product_type, index in @props.availableProductTypes
      is_disabled = _.contains(@props.selectedTypes, product_type.id)
      productTypeOptions.push(
        `<option value={product_type.id} disabled={is_disabled} key={product_type.id}>
          {product_type.name}
        </option>`
      )

    unless (new_product || @props.index == 0)
      closeIcon = `<i className="wt-product-type__remove icon-close" onClick={this._removeProduct}></i>`

    return (
      `<div className="wt-product-type">
        {closeIcon}

        <div className="wt-product-type__select select-wrapper">
          <select ref="product_type_id" defaultValue={this.state.productTypeID} key={this.props.productTypeID} onChange={this._onChange} >
            <option value={0} disabled={true}>select type...</option>
            {productTypeOptions}
          </select>
        </div>

        <div className="wt-product-type__checkbox">
          <label>
            <input ref="product_is_inforce" type="checkbox" onChange={this._onChange} checked={this.state.isInforce} disabled={new_product} />
            In-force
          </label>
        </div>
      </div>`
    )

#-----------  Export  -----------#

module.exports = ProductType

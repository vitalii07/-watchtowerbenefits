#-----------  Requirements  -----------#

ProductType = require('components/modals/steps/product_type')

#-----------  React Componet Class  -----------#

RFPProductInfo = React.createClass

  propTypes:
    projectData : React.PropTypes.object.isRequired
    saveValues  : React.PropTypes.func.isRequired
    goToStep    : React.PropTypes.func.isRequired

  getInitialState: ->
    prod_types = @props.projectData.product_types || []
    products   = @props.projectData.products || []

    return {
      selectedTypes : @_selectedTypes(products)
      productTypes  : prod_types
      products      : if (!_.isEmpty(prod_types) && _.isEmpty(products)) then [@_newDefaultProduct()] else products
      canAddProduct : if _.isEmpty(products) then false else @_canAddProduct(products, prod_types)
      isValid       : if _.isEmpty(products) then false else @_hasValidProducts(products)
    }

  #-----------  Product Types AJAX  -----------#

  componentDidMount: ->
    return false unless _.isEmpty(@state.productTypes)

    $.ajax
      type: "GET",
      url: "/product_types",
      dataType: "json",
      error: (jqXHR, textStatus, errorThrown) =>
        return false
      success: (data, textStatus, jqXHR) =>
        @setState {
          productTypes : data.product_types
          products     : [@_newDefaultProduct()]
        }

  #-----------  Helpers  -----------#

  _newDefaultProduct: ->
    return {
      inforce         : false
      product_type_id : 0
    }

  _selectedTypes: (products) ->
    return _.map(products, (product) -> return parseInt(product.product_type_id)) || []

  _canAddProduct: (products, product_types = null) ->
    prod_types = product_types || @state.productTypes
    has_empty  = (_.last(products).product_type_id != 0)
    more_types = (products.length < prod_types.length)
    return (has_empty && more_types)

  _hasValidProducts: (products) ->
    product = _.findWhere(products, (product) -> return product.product_type_id != 0)
    return if product then true else false

  _cleanProducts: ->
    return _.filter(@state.products, (product) -> return !(product.product_type_id == 0))

  #-----------  Event Handlers  -----------#

  _addProduct: ->
    products = _.clone(@state.products)
    products.push(@_newDefaultProduct())
    @setState {
      products      : products
      canAddProduct : false
    }

  _removeProduct: (index) ->
    products = _.clone(@state.products)
    products.splice(index, 1)
    @setState {
      products      : products
      selectedTypes : @_selectedTypes(products)
      canAddProduct : true
      isValid       : @_hasValidProducts(products)
    }

  _saveProduct: (product) ->
    products = _.clone(@state.products)
    products[product.index] = {
      id              : product.model_id
      inforce         : product.inforce
      product_type_id : product.product_type_id
    }

    @setState {
      products      : products
      selectedTypes : @_selectedTypes(products)
      canAddProduct : @_canAddProduct(products)
      isValid       : @_hasValidProducts(products)
    }

  #-----------  HTML Element Render  -----------#

  render: ->
    productTypeComponents = []

    for product, index in @state.products
      key = index + '_' + product.product_type_id
      productTypeComponents.push(
        `<ProductType
          key={key}
          index={index}
          availableProductTypes={this.state.productTypes}
          selectedTypes={this.state.selectedTypes}
          productTypeID={product.product_type_id}
          isInforce={product.inforce}
          removeProduct={this._removeProduct}
          saveProduct={this._saveProduct}
          model_id={product.id}
        />`
      )

    return (
      `<div className="wt-new-project-wizard__step wt-new-project-wizard__step--one">
        <small>Step 2 of 3</small>

        <h2 className="wt-modal__title">Enter RFP Product Info</h2>
        <p>Enter which products your RFP will include, and if they’re currently in-force. Please note that only products listed as being part of the RFP will have their policies reviewed.</p>

        <div className="wt-formfield">
          <div className="wt-products-list">
            {productTypeComponents}
          </div>

          <button disabled={!this.state.canAddProduct} onClick={this._addProduct} className="button-alt">
            <i className="icon-plus"></i>
            Add Product
          </button>

          <div className="wt-new-project-wizard__progress-buttons">
            <button className="button-alt" onClick={this._goBack}>Prev</button>
            <button disabled={!this.state.isValid} onClick={this._saveAndContinue}>Next</button>
          </div>
        </div>
      </div>`
    )

  #-----------  Save & Continue  -----------#

  _goBack: ->
    @props.saveValues(
      product_types : @state.productTypes
      products      : @_cleanProducts()
    )
    @props.goToStep(1)

  _saveAndContinue: ->
    has_id    = (!_.isEmpty(@props.projectData.project) && @props.projectData.project.id)
    ajax_url  = if has_id then "/projects/#{@props.projectData.project.id}" else '/projects'
    ajax_type = if has_id then 'PUT' else 'POST'
    effective_date = moment(@props.projectData.effective_date).format('DD/MM/YYYY')

    $.ajax
      url: ajax_url
      type: ajax_type
      dataType: "json"
      data:
        employer_name: @props.projectData.employer_name
        project:
          employer_id: null
          effective_date: effective_date
          project_product_types_attributes: @_cleanProducts()

      error: (jqXHR, textStatus, errorThrown) =>
        # TODO: handle error state

      success: (data, textStatus, jqXHR) =>
        @props.saveValues(
          product_types : @state.productTypes
          products      : data.project.project_product_types
          project       : data.project
        )
        @props.goToStep(3)

#-----------  Export  -----------#

module.exports = RFPProductInfo

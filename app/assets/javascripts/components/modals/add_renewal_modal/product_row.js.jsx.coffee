ClassRow = require('components/modals/add_renewal_modal/class_row')

ProductRow = React.createClass
  propTypes:
    product: React.PropTypes.object.isRequired
    updateInputValue: React.PropTypes.func.isRequired
    valuesLibrary: React.PropTypes.object
    applyToAllClasses: React.PropTypes.func

  getInitialState: -> ({openAdvanced: false, open: false})

  updateRate: (e) -> @props.updateInputValue(@props.product, 'Rate', e.currentTarget.value)
  updateRateGuarantee: (e) -> @props.updateInputValue(@props.product, 'Rate Guarantee', e.currentTarget.value)

  advanced: ->
    advancedHidden = React.addons.classSet({hidden: !@state.openAdvanced})
    return `<div className={'advanced ' + advancedHidden}>
      <table className='_renewal__class-table'>
        <tbody>
          <tr>
            <td className='_renewal__value-name-column'>Rate</td>
            <td className='_renewal__value-value-column'></td>
            <td className='_renewal__value-new-value-column'>
              <input onChange={this.updateRate}/>
            </td>
          </tr>
        </tbody>
      </table>
      <button className='_renewal__apply-to-all-classes'
        onClick={function() { this.props.applyToAllClasses(this.props.product) }.bind(this) }>
        APPLY TO ALL CLASSES
      </button>
    </div>`

  toggleAdvanced: -> @setState({openAdvanced: !@state.openAdvanced})
  toggleProduct: -> @setState({open: !@state.open})

  classRow: (pc, product) ->
    return `<ClassRow
      key={pc.id}
      pc={pc}
      product={product}
      valuesLibrary={this.props.valuesLibrary}
      updateInputValue={this.props.updateInputValue} />
    `

  render: ->
    product = @props.product
    open = @state.open
    valuesLibrary = @props.valuesLibrary
    arrow_right_hidden = React.addons.classSet({hidden: open})
    arrow_down_hidden = React.addons.classSet({hidden: !open})
    sorted_classes = _.sortBy(product.product_classes, 'class_number')

    return `<div className='_renewal__product-container' key={product.id}>
      <div className='_renewal__product-row'>
        {product.name}
        <span className={'_renewal__advanced-text ' + arrow_down_hidden} onClick={this.toggleAdvanced} >
          (Advanced)
        </span>
        <i className={"icon-right _renewal__icon " + arrow_right_hidden} onClick={this.toggleProduct} />
        <i className={"icon-down _renewal__icon " + arrow_down_hidden} onClick={this.toggleProduct} />
      </div>
      <div className={'_renewal__product-settings ' + arrow_down_hidden}>
        {this.advanced()}
        <div className='_renewal__rate-guarantee'>
          <div className='_renewal__rate-guarantee--header'>Rate Guarantee</div>
          <div className='_renewal__rate-guarantee--input'>
            <input value={valuesLibrary[product.id]['Rate Guarantee']} onChange={this.updateRateGuarantee} />
          </div>
        </div>
        {sorted_classes.map(function(pc) { return this.classRow(pc, product) }.bind(this) )}
      </div>
    </div>`

module.exports = ProductRow

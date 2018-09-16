rateValues = require('components/modals/add_renewal_modal/helpers').rateValues
ValueRowString = require('components/modals/add_renewal_modal/value_row_string')
ValueRowCompound = require('components/modals/add_renewal_modal/value_row_compound')

ClassRow = React.createClass
  propTypes:
    pc: React.PropTypes.object.isRequired
    product: React.PropTypes.object.isRequired
    valuesLibrary: React.PropTypes.object.isRequired
    updateInputValue: React.PropTypes.func.isRequired

  updateValueCallback: (valueId) ->
    ((value) -> @props.updateInputValue(@props.product, valueId, value)).bind(this)

  valueRow: (value) ->
    inputValue = @props.valuesLibrary[@props.product.id][value.id]
    updateValue = @updateValueCallback(value.id)
    if value.compound
      return `<ValueRowCompound key={value.id} value={value} inputValue={inputValue} updateValue={updateValue} />`
    return `<ValueRowString key={value.id} value={value} inputValue={inputValue} updateValue={updateValue} />`

  render: ->
    pc = @props.pc
    product = @props.product

    rate_values = _.sortBy(rateValues(pc), 'order')
    rate_values = rate_values.filter((rv) -> !rv.name.includes('Rate Guarantee'))

    return `<div key={pc.id}>
      <table className='_renewal__class-table'>
        <thead className='_renewal__table-header'>
          <tr>
            <td className='_renewal__value-name-column'>{pc.name}</td>
            <td className='_renewal__value-value-column'>Current</td>
            <td className='_renewal__value-new-value-column'>Renewal</td>
          </tr>
        </thead>
        <tbody>
          {rate_values.map(function(val) { return this.valueRow(val) }.bind(this) )}
        </tbody>
      </table>
    </div>`

module.exports = ClassRow

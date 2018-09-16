AGE_BAND_LABELS = ['age_0_19', 'age_20_24', 'age_25_29', 'age_30_34', 'age_35_39', 'age_40_44', 'age_45_49', 'age_50_54',
  'age_55_59', 'age_60_64', 'age_65_69', 'age_70_74', 'age_75_79', 'age_80_plus']
COMPOSITE_LABELS = ['composite']

ValueRowCompound = React.createClass
  propTypes:
    value: React.PropTypes.object.isRequired
    inputValue: React.PropTypes.object
    updateValue: React.PropTypes.func

  getInitialState: -> ({selectedType: undefined})

  composite: ->
    _.isEqual(_.keys(@props.value.value), COMPOSITE_LABELS)

  label:
    age_0_19: '0-19'
    age_20_24: '20-24'
    age_25_29: '25-29'
    age_30_34: '30-34'
    age_35_39: '35-39'
    age_40_44: '40-44'
    age_45_49: '45-49'
    age_50_54: '50-54'
    age_55_59: '55-59'
    age_60_64: '60-64'
    age_65_69: '65-69'
    age_70_74: '70-74'
    age_75_79: '75-79'
    age_80_plus: '80+'

  ageRowView: (label) ->
    if @composite()
      return `<tr key={label} className='_renewal__compound__table-row'>
        <td>${this.props.value.value[label]}</td>
      </tr>`
    return `<tr key={label} className='_renewal__compound__table-row'>
      <td className='_renewal__compound__label'>{this.label[label]}</td>
      <td className='_renewal__compound__age-banded-value'>${this.props.value.value[label]}</td>
    </tr>`

  getUpdateFunction: (label) ->
    ((e) ->
      newValue = {}
      newValue[label] = e.target.value
      compoundValue = Object.assign({}, @props.inputValue, newValue, {type: @selectedType()})
      @props.updateValue(compoundValue)
    ).bind(this)

  ageRowEdit: (label) ->
    value = this.props.inputValue && this.props.inputValue[label]
    return `<tr key={label} className='_renewal__compound__table-row'>
      <td className='_renewal__compound__label'>{this.label[label]}</td>
      <td className='_renewal__compound__age-banded-value'>
        <input className='_renewal__compound__input' value={value} onChange={this.getUpdateFunction(label)}/>
      </td>
    </tr>`

  updateSelectedType: (e) ->
    compoundValue = Object.assign({}, @props.inputValue, {type: e.target.value})
    @props.updateValue(compoundValue)
    @setState({selectedType: e.target.value})

  labelsForInputs: ->
    return (if @selectedType() == 'Age Banded' then AGE_BAND_LABELS else COMPOSITE_LABELS)

  selectedType: ->
    @state.selectedType || (if @composite() then 'Composite' else 'Age Banded')

  render: ->
    value = @props.value
    inputValue = @props.inputValue
    updateValue = @props.updateValue

    return `<tr className='_renewal__table-row _renewal__table-row-compound'>
      <td>{value.name}</td>
      <td>
        <div className='_renewal__compound__title'>
          {this.composite() ? 'Composite' : 'Age Banded'}
        </div>
        <table className='_renewal__compound__table'>
          <tbody>
            {Object.keys(value.value).sort().map(this.ageRowView)}
          </tbody>
        </table>
      </td>
      <td>
        <div className='select-wrapper'>
          <select value={this.selectedType()} onChange={this.updateSelectedType}>
            <option value='Age Banded'>Age Banded</option>
            <option value='Composite'>Composite</option>
          </select>
        </div>
        <table className='_renewal__compound__update-values-table'>
          <tbody>
            {this.labelsForInputs().sort().map(this.ageRowEdit)}
          </tbody>
        </table>
      </td>
    </tr>`

module.exports = ValueRowCompound
module.exports.AGE_BAND_LABELS = AGE_BAND_LABELS
module.exports.COMPOSITE_LABELS = COMPOSITE_LABELS

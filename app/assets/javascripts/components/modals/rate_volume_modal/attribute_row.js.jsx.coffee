groupClassNumbers = require('utils/utility_functions').groupClassNumbers
isUsableNumber   = require('utils/utility_functions').isUsableNumber
AGE_BAND_LABELS = require('components/modals/add_renewal_modal/value_row_compound').AGE_BAND_LABELS
COMPOSITE_LABELS = require('components/modals/add_renewal_modal/value_row_compound').COMPOSITE_LABELS

AttributeRow = React.createClass
  propTypes:
    attribute: React.PropTypes.object
    totalVolume: React.PropTypes.number
    isPolicy: React.PropTypes.bool
    updateVolume: React.PropTypes.func
    updateRateBasis: React.PropTypes.func
    defaultRateBasis: React.PropTypes.any

  getInitialState: ->
    data = {}
    for klasses in @props.attribute.classes
      klass = klasses[0] - 1
      attr = @props.attribute.values[klass]
      if attr.compound
        for label in @labelsForAttribute(attr)
          data[klass] ||= {}
          age_attr = _.find attr.age_bands, (age_band) -> age_band.label == label
          data[klass][label] = {volume: age_attr.volume, rate_basis: @rateBasisValue(attr.key, age_attr.rate_basis, label)}
      else
        data[klass] = {volume: attr.volume, rate_basis: @rateBasisValue(attr.key, attr.rate_basis)}
    data: data
    diffVolume: @diffVolume(data)

  displayLabel:
    composite: 'Composite'
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

  rateBasisValue: (attributeId, rate_basis, label = null) ->
    if isUsableNumber(rate_basis)
      rate_basis
    else
      @props.updateRateBasis(attributeId, @props.defaultRateBasis, label)
      @props.defaultRateBasis

  updateRateBasisFunc: (klass, label = null) ->
    that = @
    ((e) ->
      that.updateRateBasisValue(e, klass, label)
    ).bind(@)

  updateVolumeFunc: (klass, label = null) ->
    that = @
    ((e) ->
      that.updateVolumeValue(e, klass, label)
    ).bind(@)

  updateRateBasisValue: (e, klass, label = null) ->
    currentData = @state.data
    if label
      currentData[klass][label].rate_basis = e.target.value
    else
      currentData[klass].rate_basis = e.target.value
    @setState data: currentData
    @props.updateRateBasis(@props.attribute.id, e.target.value, label)

  updateVolumeValue: (e, klass, label = null) ->
    currentData = @state.data
    if label
      currentData[klass][label].volume = e.target.value
    else
      currentData[klass].volume = e.target.value
    @setState data: currentData, diffVolume: @diffVolume(currentData)
    @props.updateVolume(@props.attribute.id, e.target.value, label)

  labelsForAttribute: (attribute) ->
    return [] unless attribute.compound
    if _.isEqual(_.keys(attribute.value), COMPOSITE_LABELS)
      COMPOSITE_LABELS
    else
      AGE_BAND_LABELS

  diffVolume: (volumes) ->
    currentVolume = 0
    for klass, attr of volumes
      if @props.attribute.values[klass].compound
        for label, labelValue of attr
          currentVolume += parseInt(labelValue.volume) if !!labelValue.volume
      else
        currentVolume += parseInt(attr.volume) if !!attr.volume
    (@props.totalVolume || 0) - currentVolume

  klassRow: (attribute, klasses) ->
    updateVolumeCallback = this.updateVolumeFunc
    updateRateBasisCallback = this.updateRateBasisFunc
    klass = klasses[0] - 1
    if attribute.compound
      ageBands = []
      for label, index in @labelsForAttribute(attribute)
        ageBands.push(
          `<tr>
            <td>{index == 0 ? "Classes " + groupClassNumbers(klasses) : ''}</td>
            <td className="_rate_volume_modal_value">{attribute.value[attribute.label]}</td>
            <td>{this.displayLabel[label]}</td>
            <td><input value={this.state.data[klass][label].rate_basis} onChange={updateRateBasisCallback(klass, label)}/></td>
            <td><input value={this.state.data[klass][label].volume} onChange={updateVolumeCallback(klass, label)} /></td>
          </tr>`
        )
      return ageBands
    else
      return `<tr>
        <td>Classes {groupClassNumbers(klasses)}</td>
        <td className="_rate_volume_modal_value">{attribute.value}</td>
        <td></td>
        <td><input value={this.state.data[klass].rate_basis} onChange={updateRateBasisCallback(klass)}/></td>
        <td><input value={this.state.data[klass].volume} onChange={updateVolumeCallback(klass)} /></td>
      </tr>`

  render: ->
    klassRows = []
    for klasses in @props.attribute.classes
      klass = klasses[0] - 1
      attr = this.props.attribute.values[klass]
      klassRows.push @klassRow(attr, klasses)

    diffContent = null
    unless @props.isPolicy
      diffContent = (
        `<div className="_rate_volume_modal-diff">
          Difference of In-Force Total Volume
          <span className="_rate_volume_modal-diff-value">({this.state.diffVolume})</span>
        </div>`
      )

    `<div>
        <table className="_rate_volume_modal-table">
        <thead>
          <tr>
            <th colSpan="2" className="_rate_volume_modal-table-attribute">{this.props.attribute.name}</th>
            <th className="_rate_volume_modal-table-label"></th>
            <th>Rate Basis (per)</th>
            <th>Volume</th>
          </tr>
        </thead>
        <tbody>
          {klassRows}
        </tbody>
      </table>
      {diffContent}
    </div>`

module.exports = AttributeRow

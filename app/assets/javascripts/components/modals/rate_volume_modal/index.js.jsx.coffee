Modal             = require('components/common/modal')
DataTableStore    = require('stores/data_table')
DataTableActions  = require('actions/data_table')
AGE_BAND_LABELS = require('components/modals/add_renewal_modal/value_row_compound').AGE_BAND_LABELS
COMPOSITE_LABELS = require('components/modals/add_renewal_modal/value_row_compound').COMPOSITE_LABELS

AttributeRow      = require('components/modals/rate_volume_modal/attribute_row')

RateVolumeModal = React.createClass
  propTypes:
    open: React.PropTypes.bool.isRequired
    productId: React.PropTypes.number
    documentId: React.PropTypes.number
    closeModal: React.PropTypes.func

  getInitialState: ->
    attributes: {}
    isPolicy: true
    document: {}
    updateData: {}
    totalVolumeData: {}
    defaultRateBasis: 0

  componentWillReceiveProps: (new_props) ->
    if new_props.productId && new_props.documentId
      rolledUp = @getDocumentData(new_props.productId, new_props.documentId)
      defaultRateBasis = DataTableStore.getColumnsingleProductInformation(new_props.documentId).rate_denominator
      isPolicy = DataTableStore.getInforceDocument() == new_props.documentId
      document = _.findWhere DataTableStore.getColumns(), {id: new_props.documentId}
      totalVolumeData = DataTableStore.getTotalVolumeData(new_props.productId, DataTableStore.getInforceDocument())
      @setState(attributes: rolledUp, isPolicy: isPolicy, document: document, totalVolumeData: totalVolumeData, defaultRateBasis: defaultRateBasis)
    else
      @setState(@getInitialState())

  titleText: ->
    title = if @state.isPolicy
              'All Proposals'
            else
              @state.document.carrier.name
    "Enter Volumes (#{title})"

  attributeRows: (attributes) ->
    rows = []
    for attributeId, attribute of attributes
      rows.push(
        `<AttributeRow
          key={attribute.key}
          attribute={attribute}
          updateVolume={this.updateVolume}
          updateRateBasis={this.updateRateBasis}
          totalVolume={this.state.totalVolumeData[attributeId]}
          isPolicy={this.state.isPolicy}
          defaultRateBasis={this.state.defaultRateBasis}
        />`
      )
    rows

  updateVolume: (attributeId, volume, label = null) ->
    data = @state.updateData
    data[attributeId] ||= {}
    volume = 0 unless volume
    if label
      data[attributeId][label] ||= {}
      data[attributeId][label].volume = volume
    else
      data[attributeId].volume = volume
    @setState(updateData: data)

  updateRateBasis: (attributeId, rate_basis, label = null) ->
    data = @state.updateData
    data[attributeId] ||= {}
    rate_basis = 0 unless rate_basis
    if label
      data[attributeId][label] ||= {}
      data[attributeId][label].rate_basis = rate_basis
    else
      data[attributeId].rate_basis = rate_basis
    @setState(updateData: data)

  getDocumentData: (productId, documentId) ->
    documentRows = DataTableStore.getRows()[productId]
    attributes = DataTableStore.rateAttributes(documentRows, documentId)
    rolledUp = DataTableStore.rateRollup(attributes)

  attributeLabels: (attribute) ->
    return [] unless attribute.compound
    if _.isEqual(_.keys(attribute.value), COMPOSITE_LABELS)
      COMPOSITE_LABELS
    else
      AGE_BAND_LABELS

  collectDocumentData: (documentId, volumeData, classes = []) ->
    documentData = @getDocumentData(@props.productId, documentId)
    data = {}
    for attributeId, value of volumeData
      attributeId = parseInt(attributeId)
      classes = @state.attributes[attributeId].classes
      continue unless documentData[attributeId]
      sameClass = _.isEqual classes, documentData[attributeId].classes, (a, b) -> _.isEqual(a, b)
      continue unless sameClass
      dValue = _.find documentData[attributeId].values, (value) -> value.key == attributeId
      continue unless dValue

      if dValue.compound
        for label, labelValue of value
          age_attr = _.find dValue.age_bands, (age_band) -> age_band.label == label
          continue unless age_attr
          continue if documentId != @props.documentId && !!age_attr.volume && age_attr.volume != labelValue.volume
          data[age_attr.id] = labelValue
      else
        continue if documentId != @props.documentId && !!dValue.volume && dValue.volume != value.volume
        data[dValue.id] = value
    data

  collectProjectData: (volumeData) ->
    documents = []
    if @state.isPolicy
      documents = _.pluck DataTableStore.getColumns(), 'id'
    else
      documents = [@props.documentId]
    projectData = {}
    for documentId in documents
      documentData = @collectDocumentData(documentId, volumeData, @state.attributes.classes)
      _.extend(projectData, documentData)
    projectData

  processUpdate: ->
    dynamic_values = @collectProjectData(@state.updateData)
    unless _.isEmpty(dynamic_values)
      DataTableActions.changeVolume(@props.productId, dynamic_values)
    @props.closeModal()

  render: ->
    attributeRows = @attributeRows(@state.attributes)
    `<Modal title={this.titleText()} wtModalBlockStyle={{maxWidth: '700px'}}
      isOpen={this.props.open}
      closeModalCallback={this.props.closeModal} >
      <div className='_rate_volume_modal-container'>
        {attributeRows}
        <button className="_rate_volume_modal-submit" onClick={this.processUpdate}>Submit Volume</button>
      </div>
    </Modal>`

module.exports = RateVolumeModal
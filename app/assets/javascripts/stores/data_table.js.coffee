#-----------  Requirements  -----------#

DataTableConstants  = require('constants/data_table')
DataTableDispatcher = require('dispatchers/data_table')
LocalStorageAdapter = require('utils/local_storage_adapter')
ProjectSerializer   = require('utils/project_serializer')
PersistanceLayer    = require('utils/persistance_layer')

isColumnVisible = require('utils/utility_functions').isColumnVisible
isUsableNumber  = require('utils/utility_functions').isUsableNumber
isRowVisible    = require('utils/utility_functions').isRowVisible
EventEmitter    = require('events').EventEmitter
assign          = require('object-assign')

ActionTypes  = DataTableConstants.ActionTypes
CHANGE_EVENT = 'change'

#-----------  Module  -----------#

DataTableStore = assign {}, EventEmitter.prototype,

  init: ->
    @_project = window._DATA.project # TODO: possibly make this an ajax call?

    serializer = new ProjectSerializer(@_project)
    LocalStorageAdapter.storageInitialization(@_project.id, @_project.view_options)

    @_columns     = serializer.columns
    @_products    = serializer.products
    @_rows        = serializer.rows
    @_classRollup = serializer.classRollup
    @_contextualContents = serializer.contextualContents
    @_rollUp      = @_project.rollup_classes
    @_classMap    = serializer.classMap

    @_setColumnOrder()
    @_setNonContributoryProducts()
    @_setComparisonRates()
    @_setSortableBounds()
    @_setFilters()
    @_setSold()
    @_setPolicyDocument()

  #-----------  Dynamic Setters  -----------#

  _setFilters: (selected_product, selected_class, show_advanced, show_ignored_attributes) ->
    @_currentProduct        = selected_product || @_defaultProduct()
    @_currentClass          = selected_class || @_defaultClass()
    @_showAdvanced          = if _.isBoolean(show_advanced) then show_advanced else @getAdvancedToggle()
    @_showIgnoreAttributes  = if _.isBoolean(show_ignored_attributes) then show_ignored_attributes else @getIgnoredToggle()

  _setColumnOrder: ->
    columns = @getColumns()
    order = LocalStorageAdapter.getColumnsorting()

    return false if _.isEmpty(order)

    visible_columns = []
    pending_columns = []

    # sort previously order columns
    for column_id in order
      column = _.findWhere(columns, {id: column_id})
      if column
        if isColumnVisible(column)
          visible_columns.push(column)
        else
          pending_columns.push(column)

    # sort previously order columns
    for column in columns
      if (column && _.indexOf(order, column.id) == -1)
        if isColumnVisible(column)
          visible_columns.push(column)
        else
          pending_columns.push(column)

    # combine ordered columns
    ordered_columns = visible_columns.concat(pending_columns)

    policies = ordered_columns.filter((c) -> c.document_type == 'Policy')
    renewals = ordered_columns.filter((c) -> c.renewal)
    proposals = ordered_columns.filter((c) -> c.document_type == 'Proposal' && !c.renewal)
    ordered_columns = _.flatten([policies, renewals, proposals])

    # update stores
    updated_id_array = _.map(ordered_columns, (column) -> return column.id)
    LocalStorageAdapter.setColumnSorting(updated_id_array)
    @_columns = ordered_columns

  #-----------  Static Setters  -----------#

  _setSortableBounds: ->
    columns = @getColumns()
    policy_and_renewals_count = _.countBy(columns, (column) -> column.document_type == 'Policy' || column.renewal)
    finalized_proposal_count = _.countBy(columns, (column) -> return (column.document_type == 'Proposal' && column.state == 'finalized'))

    if policy_and_renewals_count.true > 0
      @_leftSortableBound = policy_and_renewals_count.true
      @_rightSortableBound = finalized_proposal_count.true || policy_and_renewals_count.true
    else
      @_leftSortableBound = 0
      @_rightSortableBound = (finalized_proposal_count.true - 1) || 0

  _setComparisonRates: ->
    @_comparisonRates = []
    comparison_column = _.findWhere(@_columns, { document_type: 'Policy' })
    if comparison_column
      @_comparisonRates = _.mapObject comparison_column.product_information, (information, product_id) ->
        return information.unit_rate

  _setNonContributoryProducts: ->
    @_nonContributoryProducts = _.filter @_products, (product) ->
      return product.has_non_contributory

  _setSold: ->
    @_hasSold = !_.isEmpty(_.findWhere(@getColumns(), { is_sold: true }))

  _setPolicyDocument: ->
    policy = _.findWhere(@_columns, {document_type: 'Policy'})
    @_policyDocument = policy.id if policy

  #-----------  Default Setters  -----------#

  _defaultProduct: ->
    for product in @getOrderedProducts()
      return product.product_id unless _.isEmpty(product.product_classes)
    return ''

  _defaultClass: ->
    default_product_array = @getProducts()[@_defaultProduct()] || []
    for klass_id, klass of default_product_array.product_classes
      return klass_id
    return ''

  _filterUnstatedRows: (rows) ->
    _.filter rows, (row) ->
      isRowVisible(row)

  #-----------  Simple Getters  -----------#

  getRows: ->
    return @_rows

  getColumns: ->
    return @_columns

  getOrderedProducts: ->
    return _.sortBy(_.sortBy(_.values(@getProducts()), 'name'), 'product_position')

  getProducts: ->
    return @_products

  hasSoldProposal: ->
    return @_hasSold

  getCurrentProduct: ->
    return @_currentProduct

  getCurrentClass: ->
    return @_currentClass

  getComparisonRates: ->
    return @_comparisonRates

  getLeftSortableBound: ->
    return @_leftSortableBound

  getRightSortableBound: ->
    return @_rightSortableBound

  getNonContributoryProducts: ->
    return @_nonContributoryProducts

  getInforceDocument: ->
    return @_policyDocument

  #-----------  Getters  -----------#

  getFilteredRows: ->
    if @_rollUp
      filteredRows = []
      productRows = @getRows()[@getCurrentProduct()] || []
      for row, rowIndex in productRows[@_defaultClass()]
        if row.sidebar.is_grouping
          row.sidebar.classNumbers = []
          filteredRows.push row
        else
          attributeId = row.sidebar.row_id
          rollupData = @_classRollup[@getCurrentProduct()][attributeId]
          if rollupData
            showAttribute = false
            for klasses, index in rollupData
              classRow = _.clone(productRows[klasses[0]][rowIndex], true)
              classRow.sidebar.classNumbers = klasses
              classRow.sidebar.showClassNumbers = rollupData.length > 1
              if showAttribute
                classRow.sidebar.showAttributeName = false
              else
                classRow.sidebar.showAttributeName = !LocalStorageAdapter.isRowCollapsed(attributeId, klasses[0]) && isRowVisible(classRow)
                showAttribute = true if classRow.sidebar.showAttributeName
              filteredRows.push classRow
    else
      filteredRows = @getRows()[@getCurrentProduct()][@getCurrentClass()] || []
    filteredRows = if @getAdvancedToggle() then filteredRows else _.filter filteredRows, (row) -> !row['sidebar'].is_advanced
    filteredRows = if @getIgnoredToggle() then filteredRows else _.filter filteredRows, (row) -> !row['sidebar'].is_ignored
    filteredRows = @_filterUnstatedRows(filteredRows)
    filteredRows

  getVisibleColumns: ->
    columns = @getColumns()
    return _.filter columns, (column) -> return isColumnVisible(column)

  getAdvancedToggle: ->
    product_id = @getCurrentProduct()
    return LocalStorageAdapter.isAdvancedProduct(product_id)

  getIgnoredToggle: ->
    return false
    product_id = @getCurrentProduct()
    return LocalStorageAdapter.isShowAllProduct(product_id)

  getProductVolume: ->
    product_id = @getCurrentProduct()
    return LocalStorageAdapter.getProductVolume(product_id)

  getComparisonRate: ->
    product_id = @getCurrentProduct()
    return @getComparisonRates()[product_id] || null

  getColumnsingleProductInformation: (column_id) ->
    product_info = _.findWhere(@_columns, { id: column_id }).product_information || {}
    return product_info[@getCurrentProduct()] || {}

  getColumnAllProductInformation: (column_id) ->
    product_info = _.findWhere(@_columns, { id: column_id }).product_information || {}
    return product_info

  getProductDenominators: ->
    products     = @getNonContributoryProducts()
    columns      = @getVisibleColumns()
    denominators = {}

    for product in products
      product_id = product.product_id
      denominators[product_id] = null

      for column in columns
        if column.product_information
          if column.product_information[product_id]
            value = column.product_information[product_id].rate_denominator
            denominators[product_id] = value if isUsableNumber(value)
    return denominators

  getProjectViewOptions: ->
    viewOptions = LocalStorageAdapter.getAllProjectData(@_project.id)
    return viewOptions

  getContextualContents: (attributeId) ->
    @_contextualContents[attributeId]

  #-----------  Checks  -----------#

  isProductNonConributory: (product_id = 0) ->
    product_id = product_id || @getCurrentProduct()
    return @getProducts()[product_id].has_non_contributory

  isClassRollup: ->
    return @_classRollup

  isClassQuoted: (column_id, class_number) ->
    _.indexOf(@_classMap[column_id][@getCurrentProduct()], class_number) != -1

  hasContextualContent: (attributeId) ->
    !!@_contextualContents[attributeId]

  #------------ Rate Volume Helpers -----------#
  attributeValue: (attribute) ->
    attribute.value

  rateAttributes: (rows, documentId) ->
    attributes = {}
    for klass, classRows of rows
      for row in classRows
        if row.sidebar.row_id && row[documentId].is_rate
          attributes[row.sidebar.row_id] ||= []
          attributes[row.sidebar.row_id].push row[documentId]
    attributes

  rateRollup: (attributes) ->
    rollUp = {}
    for attributeId, values of attributes
      rollUp[attributeId] = {name: values[0].name, id: attributeId}
      rollUp[attributeId].values = values
      rollUp[attributeId].classes = []
      classSize = values.length
      startIndex = 0
      currentPos = 0
      classes = []
      pickedClasses = []
      for startIndex in [0..classSize - 1] by 1
        continue if pickedClasses.includes(startIndex)
        classes = [startIndex + 1]
        for currentPos in [startIndex + 1..classSize - 1] by 1
          continue if pickedClasses.includes(currentPos)
          if _.isEqual(@attributeValue(values[startIndex]), @attributeValue(values[currentPos]))
            classes.push currentPos + 1
            pickedClasses.push currentPos
        rollUp[attributeId].classes.push classes
    rollUp

  hasVolumeData: (productId, documentId) ->
    rows = @getRows()[productId]
    rateAttributes = @rateAttributes(rows, documentId)
    rolledUp = @rateRollup(rateAttributes)
    for attributeId, values of rolledUp
      for klasses in values.classes
        klass = klasses[0] - 1
        return true if values.values[klass].volume
    false

  getRateVolumeData: (productId, documentId) ->
    rows = @getRows()[productId]
    rateAttributes = @rateAttributes(rows, documentId)
    rolledUp = @rateRollup(rateAttributes)

  getTotalVolumeData: (productId, documentId) ->
    rolledUp = @getRateVolumeData(productId, documentId)
    totalData = {}
    for attributeId, values of rolledUp
      for klasses in values.classes
        klass = klasses[0] - 1
        value = values.values[klass]
        totalData[attributeId] ||= 0
        if value.compound
          for age_attr in value.age_bands
            totalData[attributeId] += parseInt(age_attr.volume) if age_attr.volume
        else
          totalData[attributeId] += parseInt(value.volume) if value.volume
    totalData

  _updateVolume: (productId, data) ->
    for klass, attributes of @getRows()[productId]
      for row in attributes
        for documentId, attribute of row
          if attribute.compound
            for age_attr in attribute.age_bands
              if data[age_attr.id]
                age_attr.volume = data[age_attr.id].volume if data[age_attr.id].volume
                age_attr.rate_basis = data[age_attr.id].rate_basis if data[age_attr.id].rate_basis
          else
            if data[attribute.id]
              attribute.volume = data[attribute.id].volume if data[attribute.id].volume
              attribute.rate_basis = data[attribute.id].rate_basis if data[attribute.id].rate_basis
    true

  getInforceMonthlyPremiumValue: (productId) ->
    @getMonthlyPremiumValue(productId, @getInforceDocument()).premiumValue

  getMonthlyPremiumValue: (productId, documentId) ->
    rolledUp = @getRateVolumeData(productId, documentId)
    monthlyValue = 0
    unitRate = 0
    for attributeId, attributeData of rolledUp
      for klasses in attributeData.classes
        klass = klasses[0] - 1
        attribute = attributeData.values[klass]
        attributeList = []
        if attribute.compound
          attributeList = attribute.age_bands
        else
          attributeList.push attribute
        for attr in attributeList
          value = parseFloat(attr.value)
          volume = parseInt(attr.volume)
          rate_basis = parseFloat(attr.rate_basis)
          if isUsableNumber(value)
            unitRate += value
          if isUsableNumber(value) && isUsableNumber(volume) && isUsableNumber(rate_basis)
            monthlyValue += value / rate_basis * volume
    {unitRate: unitRate, premiumValue: monthlyValue}

  #-----------  Hieght Calculations  -----------#

  calculateRowHieght: (row_object) ->
    row_id = row_object.sidebar.row_id || null
    attribute_class = row_object.sidebar.classNumbers[0]

    if row_object.sidebar.is_grouping
      return 30
    else if LocalStorageAdapter.isRowCollapsed(row_id, attribute_class)
      return 12
    else
      height = 50
      row_count = 0

      for index, column of @getColumns()
        if row_object[column.id]
          entry = row_object[column.id].value || ''

          if _.isObject(entry)
            # object entries (ex. age-banded rates)
            rows = _.keys(entry).length
            if rows > row_count
              row_count = rows
              height = parseInt((rows * 27.4) + 12)

          else if entry.length > 60
            # long string entries
            # TODO: make more robust calculation
            lines = Math.ceil(entry.length/28)
            entry_height = (lines * 15) + 20
            height = entry_height if (entry_height > height)

      return height

  calculateFooterHeight: (is_expanded = false) ->
    if is_expanded
      nonContributaryProductCount = DataTableStore.getNonContributoryProducts().length || 0
      footerHeight = (60 * nonContributaryProductCount) + 76
    else if @isProductNonConributory()
      return 136
    else
      return 38

  #-----------  Change Listeners  -----------#

  _emitChange: ->
    @emit(CHANGE_EVENT)

  addChangeListener: (callback) ->
    @on(CHANGE_EVENT, callback)

  removeChangeListener: (callback) ->
    @removeListener(CHANGE_EVENT, callback)

  #-----------  Action Handlers  -----------#

  _toggleAttributelDiscrepency: (attribute_id, column_id, discrepency, classNumber) ->
    product = @getCurrentProduct()
    klass = classNumber || @getCurrentClass()

    for index, row of @getRows()[product][klass]
      if row[column_id].id == attribute_id
        return @_rows[product][klass][index][column_id].discrepency = discrepency

  #-----------  AJAX Callbacks  -----------#

  _toggleAttributelDiscrepencyCallback: (attribute_id, message = '') ->
    # TODO: do something w/ error states
    return false

  _selectColumnAsSoldCallback: (column_id, message = '') ->
    # TODO: do something w/ error states
    return @_emitChange()

  _toggleViewOptionCallback: (message = '') ->
    return false

  _toggleChangeVolumeCallback: (message) ->
    false

#-----------  Event Dispatchers  -----------#

DataTableStore.dispatchToken = DataTableDispatcher.register (action) ->

  switch action.type

    when ActionTypes.CHANGE_FILTERS
      LocalStorageAdapter.toggleAdvancedProduct(action.selectedProduct, action.showAdvanced) if _.isBoolean(action.showAdvanced)
      LocalStorageAdapter.toggleShowAllProduct(action.selectedProduct, action.showIgnoreAttributes) if _.isBoolean(action.showIgnoreAttributes)
      DataTableStore._setFilters(action.selectedProduct, action.selectedClass, action.showAdvanced, action.showIgnoreAttributes)
      DataTableStore._emitChange()

    when ActionTypes.CHANGE_ATTRIBUTE_DISCREPENCY
      callback = DataTableStore._toggleAttributelDiscrepencyCallback
      PersistanceLayer.onCellClick(action.attributeID, action.discrepency, callback, DataTableStore)
      DataTableStore._toggleAttributelDiscrepency(action.attributeID, action.columnID, action.discrepency, action.classNumber)
      DataTableStore._emitChange()

    when ActionTypes.COLLAPSE_ROW
      LocalStorageAdapter.toggleCollapsedRow(action.rowID, action.attributeClass, action.isCollapsed)
      callback = DataTableStore._toggleViewOptionCallback
      viewOptions = DataTableStore.getProjectViewOptions()
      PersistanceLayer.updateProjectViewOption(viewOptions, callback)
      DataTableStore._emitChange()

    when ActionTypes.CHANGE_PRODUCT_VOLUME
      product_id = DataTableStore.getCurrentProduct()
      LocalStorageAdapter.setProductVolume(product_id, action.volume)
      callback = DataTableStore._toggleViewOptionCallback
      viewOptions = DataTableStore.getProjectViewOptions()
      PersistanceLayer.updateProjectViewOption(viewOptions, callback)
      DataTableStore._emitChange()

    when ActionTypes.CHANGE_VOLUME
      product_id = DataTableStore.getCurrentProduct()
      callback = DataTableStore._toggleChangeVolumeCallback
      PersistanceLayer.updateVolume(action.data, callback)
      DataTableStore._updateVolume(action.productId, action.data, callback)
      DataTableStore._emitChange()

    when ActionTypes.RESORT_COLUMN
      columns = DataTableStore.getColumns()
      LocalStorageAdapter.resortColumns(action.columnID, action.fromIndex, action.toIndex, columns)
      DataTableStore._setColumnOrder()
      callback = DataTableStore._toggleViewOptionCallback
      viewOptions = DataTableStore.getProjectViewOptions()
      PersistanceLayer.updateProjectViewOption(viewOptions, callback)
      DataTableStore._emitChange()

    when ActionTypes.ARCHIVE_COLUMN
      callback = location.reload
      PersistanceLayer.archiveColumn(action.columnID, callback, window.location)

    when ActionTypes.SELECT_COLUMN_AS_SOLD
      callback = location.reload
      PersistanceLayer.selectColumnAsSold(action.columnID, callback, window.location)

    when ActionTypes.DELETE_COLUMN
      callback = location.reload
      PersistanceLayer.deleteColumn(action.columnID, callback, window.location)

    when ActionTypes.CREATE_RENEWAL_PROPOSAL
      callback = location.reload
      PersistanceLayer.createRenewalProposal(action.document_id, action.values, callback, window.location)

#-----------  Export  -----------#

module.exports = DataTableStore

#-----------  Requirements  -----------#

DataTableConstants  = require('constants/data_table')
DataTableDispatcher = require('dispatchers/data_table')

ActionTypes = DataTableConstants.ActionTypes

#-----------  Module  -----------#

DataTableActions =

  changeFilters: (selected_product, selected_class, show_advanced, show_ignore_attributes) ->
    DataTableDispatcher.dispatch
      type                : ActionTypes.CHANGE_FILTERS
      selectedProduct     : selected_product
      selectedClass       : selected_class
      showAdvanced        : show_advanced
      showIgnoreAttributes: show_ignore_attributes

  toggleAttributelDiscrepency: (attribute_id, column_id, discrepency, class_number = null) ->
    DataTableDispatcher.dispatch
      type        : ActionTypes.CHANGE_ATTRIBUTE_DISCREPENCY
      attributeID : attribute_id
      columnID    : column_id
      discrepency : discrepency
      classNumber : class_number

  toggleRowCollapse: (row_id, attribute_class, is_collapsed) ->
    DataTableDispatcher.dispatch
      type            : ActionTypes.COLLAPSE_ROW
      rowID           : row_id
      attributeClass  : attribute_class
      isCollapsed     : is_collapsed

  changeProductVolume: (volume) ->
    DataTableDispatcher.dispatch
      type   : ActionTypes.CHANGE_PRODUCT_VOLUME
      volume : volume

  changeVolume: (productId, data) ->
    DataTableDispatcher.dispatch
      type      : ActionTypes.CHANGE_VOLUME
      data      : data
      productId : productId

  resortColumn: (column_id, from_index, to_index) ->
    DataTableDispatcher.dispatch
      type      : ActionTypes.RESORT_COLUMN
      columnID  : column_id
      fromIndex : from_index
      toIndex   : to_index

  archiveColumn: (column_id) ->
    DataTableDispatcher.dispatch
      type     : ActionTypes.ARCHIVE_COLUMN
      columnID : column_id

  selectColumnAsSold: (column_id) ->
    DataTableDispatcher.dispatch
      type     : ActionTypes.SELECT_COLUMN_AS_SOLD
      columnID : column_id

  deleteColumn: (column_id) ->
    DataTableDispatcher.dispatch
      type     : ActionTypes.DELETE_COLUMN
      columnID : column_id

  createRenewalProposal: (document_id, values) ->
    DataTableDispatcher.dispatch
      type: ActionTypes.CREATE_RENEWAL_PROPOSAL
      document_id: document_id
      values: values

#-----------  Export  -----------#

module.exports = DataTableActions

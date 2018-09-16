#-----------  Requirements  -----------#

KeyMirror = require('keymirror')

#-----------  Module  -----------#

DataTableConstants =

  ActionTypes: KeyMirror(
    CHANGE_FILTERS: null
    CHANGE_ATTRIBUTE_DISCREPENCY: null
    COLLAPSE_ROW: null
    CHANGE_PRODUCT_VOLUME: null
    CHANGE_VOLUME: null
    RESORT_COLUMN: null
    ARCHIVE_COLUMN: null
    SELECT_COLUMN_AS_SOLD: null
    DELETE_COLUMN: null
    CREATE_RENEWAL_PROPOSAL: null
  )

#-----------  Export  -----------#

module.exports = DataTableConstants

#-----------  Module  -----------#

LocalStorageAdapter =

  _project_id : ''
  _initOptions: {}
  _rows       : 'collapsed_rows'
  _advanced   : 'advanced_products'
  _volumes    : 'product_volumes'
  _sorting    : 'sorted_columns'
  _show_all   : 'show_all_products'

  storageInitialization: (project_id = 0, viewOptions = {}) ->
    @_project_id = project_id
    @_initOptions = viewOptions
    @_initialize_rows()
    @_initialize_advanced()
    @_initialize_volumes()
    @_initialize_sorting()
    @_initialize_show_all()

  #-----------  Project Data  -----------#

  getAllProjectData: (project_id = 0) ->
    @_project_id = project_id

    return {
      rows     : @_getValues(@_rows)
      advanced : @_getValues(@_advanced)
      volumes  : @_getValues(@_volumes)
      sorting  : @_getValues(@_sorting)
    }

  #-----------  I/O  -----------#

  _getValues: (type) ->
    return JSON.parse(localStorage.getItem("#{@_project_id}-#{type}"))

  _setValues: (type, values) ->
    return localStorage.setItem("#{@_project_id}-#{type}", JSON.stringify(values))

  #-----------  Collapsed Row Methods  -----------#

  _initialize_rows: ->
    data = @_initOptions.rows || {}
    for attrId in _.keys(data)
      indices = data[attrId] || []
      data[attrId] = _.map(indices, (e) -> parseInt(e))
    @_setValues(@_rows, data)

  isRowCollapsed: (row_id, attribute_index) ->
    rows = @_getValues(@_rows)
    return (_.indexOf(rows[row_id], attribute_index) != -1)

  toggleCollapsedRow: (row_id, attribute_class, is_collapsed) ->
    rows = @_getValues(@_rows)
    if is_collapsed
      rows[row_id] ||= []
      rows[row_id].push attribute_class
      rows[row_id] = _.unique(rows[row_id])
    else
      rows[row_id] ||= []
      rows[row_id] = _.without(rows[row_id], attribute_class)
    return @_setValues(@_rows, rows)

  #-----------  Advanced Toggle Methods  -----------#

  _initialize_advanced: ->
    advanced = @_getValues(@_advanced)
    @_setValues(@_advanced, []) unless (_.isArray(advanced))

  _initialize_show_all: ->
    show_all = @_getValues(@_show_all)
    @_setValues(@_show_all, []) unless (_.isArray(show_all))

  isAdvancedProduct: (product_id) ->
    advanced = @_getValues(@_advanced)
    # return (_.indexOf(advanced, product_id) != -1)
    # always show all attributes
    true

  isShowAllProduct: (product_id) ->
    show_all = @_getValues(@_show_all)
    return (_.indexOf(show_all, product_id) != -1)

  toggleAdvancedProduct: (product_id, is_advanced) ->
    advanced = @_getValues(@_advanced)
    if is_advanced
      advanced.push(product_id)
    else
      advanced = _.without(advanced, product_id)
    return @_setValues(@_advanced, _.unique(advanced))

  toggleShowAllProduct: (product_id, show_ignore_attributes) ->
    show_all = @_getValues(@_show_all)
    if show_ignore_attributes
      show_all.push product_id
    else
      show_all = _.without(show_all, product_id)
    return @_setValues(@_show_all, _.uniq(show_all))

  #-----------  Product Volume Methods  -----------#

  _initialize_volumes: ->
    volumes = @_initOptions.volumes || {}
    @_setValues(@_volumes, volumes)

  getProductVolumes: ->
    return @_getValues(@_volumes)

  getProductVolume: (product_id) ->
    volumes = @_getValues(@_volumes)
    return volumes[product_id] || null

  setProductVolume: (product_id, volume) ->
    volumes = @_getValues(@_volumes)
    volumes[product_id] = volume
    return @_setValues(@_volumes, volumes)

  #-----------  Column Sorting Methods  -----------#

  _initialize_sorting: ->
    sorting = @_initOptions.sorting || []
    sorting = _.map(sorting, (e) -> parseInt(e))
    @_setValues(@_sorting, sorting)

  getColumnsorting: ->
    return @_getValues(@_sorting)

  setColumnSorting: (sorting) ->
    return @_setValues(@_sorting, sorting)

  resortColumns: (column_id, from_index, to_index, columns) ->
    sorting = @_getValues(@_sorting)
    sorting = _.map(columns, (column) -> column.id) if _.isEmpty(sorting)
    sorting.splice(to_index, 0, sorting.splice(from_index, 1)[0])
    return @setColumnSorting(sorting)

#-----------  Export  -----------#

module.exports = LocalStorageAdapter

#-----------  Requirements  -----------#

isColumnVisible = require('utils/utility_functions').isColumnVisible
removeDuplicateObjects = require('utils/utility_functions').removeDuplicateObjects
isRowVisible = require('utils/utility_functions').isRowVisible

#-----------  Module  -----------#

class ProjectSerializer

  rows        : {}
  products    : []
  columns     : []
  classRollup : {}
  classMap    : {}
  contextualContents: {}

  _state_order: ['finalized', 'reviewed', 'needs_review', 'data_entry']

  constructor: (project) ->
    @columns      = @_assembleColumns(project)
    @classMap     = @_generateClassMap(@columns)
    @classRollup  = project.rollup_data
    @products     = @_normalizeProductsAndClasses(@columns)
    allRows       = @_serializeRowData(@columns, @products)
    @rows         = allRows # @_filterUnstatedRows(allRows)
    @contextualContents = @_generateContextualContents(project.contextual_contents)

  # ---------------
  # Generate class map to check class quoted or not
  # ---------------
  _generateClassMap: (columns) ->
    classMap = {}
    for column in columns
      classMap[column.id] = {}
      for product in column.products
        classMap[column.id][product.product_id] = _.map(product.product_classes, 'class_number')
    classMap

  _generateContextualContents: (contents) ->
    contextualData = {}
    for attributeId, data of contents
      groupedData = _.groupBy(data, 'content_type')
      contextualData[attributeId] = groupedData
    contextualData

  # ---------------
  # Combines and sorts proposals and policies
  #
  # @param: {Obj} project - all project data
  # ---------------

  _assembleColumns: (project = {}) ->
    ordered_columns = []

    activePolicies = _.filter project.policies, (policy) ->
      !policy.is_archived

    activeProposals = _.filter project.proposals, (proposal) ->
      !proposal.is_archived

    policies = activePolicies.map (policy) =>
      return if isColumnVisible(policy) then @_addProductInformation(policy) else policy

    proposals = activeProposals.map (proposal) =>
      return if isColumnVisible(proposal) then @_addProductInformation(proposal) else proposal

    # reorder so that all finalized proposals are displayed first
    grouped_columns = _.groupBy(proposals, (column) -> column.state)
    for state in @_state_order
      unless _.isEmpty(grouped_columns[state])
        ordered_columns = ordered_columns.concat(grouped_columns[state])

    # add policy to front or array (if exists) and move renewal proposals to front
    unless _.isEmpty(policies)
      renewals = _.filter(ordered_columns, (proposal) -> proposal.renewal)
      regular_proposals = _.filter(ordered_columns, (proposal) -> !proposal.renewal)
      regular_proposals.unshift(policies[0], renewals)
      ordered_columns = _.flatten(regular_proposals)

    return ordered_columns

  # ---------------
  # Adds pertinent product infromation to tpo-level columns
  # object if data is present. TODO: bring this in via JSON
  #
  # @param: {Obj} column - all columns/policies
  # ---------------

  _addProductInformation: (column) ->
    for index, product of column.products
      for index, klass of product.product_classes

        # make sure there's at least some data available
        if !_.isEmpty(klass.data)
          product_type_id = product.product_id

          if _.isEmpty(column.product_information)
            column.product_information = {}

          column.product_information[product_type_id] = {
            unit_rate        : @_findFirstInClass(product, 'unit_rate')
            rate_denominator : @_findFirstInClass(product, 'unit_rate_denominator')
            rate_guarantee   : @_findFirstInClass(product, 'rate_guarantee', false)
            is_contirbutory  : product.is_contributory
          }
          break

    return column

  # ---------------
  # Loops through product classes to find the first value
  # (if any) of the provided key.
  #
  # @param: {Obj} product
  # @param: {String} key
  # ---------------
  # ONLY KEYS THAT ARE USED: unit_rate, unit_rate_denominator, rate_guarantee

  _findFirstInClass: (product, key, is_numerical = true) ->
    for klass in product.product_classes
      if is_numerical
        return klass[key] if _.isNumber(klass[key]) && klass[key] != 0
      else
        return klass[key] if !_.isEmpty(klass[key])

    return null

  # ---------------
  # Loops through all columns to generate a comprehensive
  # and unqiue collection of all products & classes used.
  #
  # @param: {Arr} columns - array of all column objects
  # ---------------

  _normalizeProductsAndClasses: (columns = []) ->
    products_collection = {}
    columns = _.filter(columns, (column) => isColumnVisible(column))

    # interate through all columns to assemble all possible products
    for column in columns
      for product in column.products
        product_id = product.product_id
        if _.isEmpty(products_collection[product_id])
          products_collection[product_id] = _.clone(product)
          products_collection[product_id].is_empty = true
          products_collection[product_id].product_classes = {}

          # TODO: needs to reflect real data
          products_collection[product_id].has_non_contributory = @_hasNonContributoryProducts(product_id, columns)

          for klass in product.product_classes
            klass_id = klass.class_number
            products_collection[product_id].product_classes[klass_id] = _.clone(klass)
            products_collection[product_id].product_classes[klass_id].is_empty = true

            unless _.isEmpty(klass.data)
              products_collection[product_id].is_empty = false
              products_collection[product_id].product_classes[klass_id].is_empty = false

            delete products_collection[product_id].product_classes[klass_id].data
        else
          for klass in product.product_classes
            klass_id = klass.class_number
            products_collection[product_id].product_classes[klass_id] = _.clone(klass)
            products_collection[product_id].product_classes[klass_id].is_empty = true

            unless _.isEmpty(klass.data)
              products_collection[product_id].is_empty = false
              products_collection[product_id].product_classes[klass_id].is_empty = false

            delete products_collection[product_id].product_classes[klass_id].data

    # serialized products object
    return products_collection

  # ---------------
  # Checks all column products to determine if there exists
  # at least one non-contributory product accross the columns
  #
  # @param: {Int} product_id - ID of current product
  # @param: {Arr} columns - collection of all column objects
  # ---------------

  _hasNonContributoryProducts: (product_id, columns) ->
    for index, column of columns
      if !_.isEmpty(column.product_information) && !_.isEmpty(column.product_information[product_id])
        return true if !column.product_information[product_id].is_contirbutory

    return false

  # ---------------
  # Create arrays of row objects for each product/class.
  # A row object contains the cell data for each column.
  #
  # @param: {Arr} columns - collection of all column objects
  # @param: {Obj} products - colection of all products & their classes
  # ---------------

  _serializeRowData: (columns = [], products = {}) ->
    data_collection = {}
    columns = _.filter(columns, (column) => isColumnVisible(column))

    # convert products to objects for row insertion
    data_collection = _.mapObject products, (product, product_id) ->
      klass_obj = {}
      for klass_number, klass of product.product_classes
        klass_obj[klass_number] = []
      return klass_obj

    # find unique & conprehensive collection of groups & attribues
    for product, klasses of data_collection
      product_id = parseInt(product)
      for klass, rows of klasses
        klass_id = parseInt(klass)
        data_collection[product_id][klass_id] = []
        # nomarlize and sort groups for a product class
        klass_groups = @_normailzeClassGroups(product_id, klass_id, columns)

        for group in klass_groups
          # nomarlize and sort attributes in groups for a product class
          group_id = group.id
          group_attributes = @_normailzeClassGroupAttributes(group_id, product_id, klass_id, columns)

          if group_attributes
            # assemble array of row objects
            group_rows = @_assembleRowObjects(group_attributes, group, columns)
            data_collection[product_id][klass_id] = data_collection[product_id][klass_id].concat(group_rows)

    return data_collection

  _filterUnstatedRows: (rows) ->
    _.mapObject rows, (value, key) ->
      _.mapObject value, (rows, key) ->
        _.filter rows, (row) ->
          isRowVisible(row)

  # ---------------
  # Normalize and sort available groupings for a particular product
  # class accross all columns
  #
  # @param: {Int} product_id - ID of current product
  # @param: {Int} klass_id - ID of current class
  # @param: {Arr} columns - collection of all column objects
  # ---------------

  _normailzeClassGroups: (product_id, klass_id, columns) ->
    groups_collection = []

    for column in columns
      column_product_collection = _.findWhere(column.products, {product_id: product_id})

      if column_product_collection
        column_klass_collection = _.findWhere(column_product_collection.product_classes, {class_number: klass_id})

        if column_klass_collection
          for index, group of column_klass_collection.data
            groups_collection.push(group)
            
    # remove duplicate & sort groups
    clean_collection = removeDuplicateObjects(groups_collection, 'id')
    return _.sortBy(clean_collection, 'order')

  # ---------------
  # Normalize and sort available attributes for a particular product
  # class grouping accross all columns
  #
  # @param: {Int} group_id - ID of current group
  # @param: {Int} product_id - ID fo current product
  # @param: {Int} klass_id - ID of current class
  # @param: {Arr} columns - collection of all column objects
  # ---------------

  _normailzeClassGroupAttributes: (group_id, product_id, klass_id, columns) ->
    attributes_collection = []

    for column in columns
      column_product_collection = _.findWhere(column.products, {product_id: product_id})

      if column_product_collection
        product_klass_collection = _.findWhere(column_product_collection.product_classes, {class_number: klass_id})

        if product_klass_collection
          klass_group_collection = _.findWhere(product_klass_collection.data, {id: group_id})

          if klass_group_collection
            for attribute in klass_group_collection.values
              attribute.column_id = column.id if _.isObject(attribute)
              attributes_collection.push(attribute)

    # remove duplicate & sort groups
    clean_collection = removeDuplicateObjects(attributes_collection, 'id')
    return _.sortBy(clean_collection, 'order')

  # ---------------
  # Generate an array of consumable row objects for a group
  #
  # @param: {Arr} attributes - normalized/sorted array of all attributes under grouping
  # @param: {Obj} group - current group object
  # @param: {Arr} columns - array of all applicable column objects
  # ---------------

  _assembleRowObjects: (attributes, group, columns) ->
    row_array = []
    ordered_keys = _.unique(_.map(attributes, (attribute) -> attribute.key)) || []
    grouped_attributes = _.groupBy(attributes, (attribute) -> attribute.key) || {}

    row_array.push @_generateGroupingRowObject(attributes, group, columns)
    for key in ordered_keys
      row_attributes = grouped_attributes[key]
      row_array.push @_generateRowObject(key, row_attributes, columns)

    return row_array
    
  # ---------------
  # Generate a consumable grouping row object
  #
  # @param: {Arr} attributes - normalized/sorted array of all attributes under grouping
  # @param: {Obj} group - current group object
  # @param: {Arr} columns - array of all applicable column objects
  # ---------------

  _generateGroupingRowObject: (attributes, group, columns) ->
    group_row_object = {}

    # assemble each column's cell
    for column in columns
      column_id = column.id
      group_row_object[column_id] = {}

    # assemble sidebar cell
    group_row_object['sidebar'] =
      group_id     : group.id
      value        : group.name
      order        : group.order
      is_grouping  : true
      is_advanced  : !@_hasNonAdvanceAttribute(attributes)
      is_ignored   : false

    return group_row_object

  # ---------------
  # Generate a consumable row object
  #
  # @param: {Int} attribute_key - ID/key of current row
  # @param: {Obj} attributes - array of available attributes
  # @param: {Arr} columns - array of all applicable column objects
  # ---------------

  _generateRowObject: (attribute_key, attributes, columns) ->
    attribute_row_name = null
    attribute_ordering = null
    attribute_row_object = {}

    # assemble each column's cell
    for column in columns
      column_id = column.id
      attribute_row_object[column_id] = _.findWhere(attributes, {column_id: column_id}) || {}

      attribute_row_name = attribute_row_object[column_id].name if attribute_row_object[column_id].name
      attribute_ordering = attribute_row_object[column_id].order if attribute_row_object[column_id].order

    # assemble sidebar cell
    attribute_row_object['sidebar'] =
      row_id       : attribute_key
      value        : attribute_row_name
      description  : attribute_row_name == "Class Description"
      order        : attribute_ordering
      is_grouping  : false
      is_advanced  : @_hasAdvancedAttribute(attribute_row_object)
      is_ignored   : @_hasIgnoreAttribute(attribute_row_object)

    return attribute_row_object

  # ---------------
  # Checks all attributes in a row to see if any are marked advacned
  # If one is advanced, the whole row should assume to be advanced
  #
  # @param: {Arr} attributes - array of attributes in a group
  # ---------------

  _hasNonAdvanceAttribute: (attributes) ->
    for attribute in attributes
      return true if (attribute && attribute.advanced == false)

    return false

  # ---------------
  # Checks all attributes in a row to see if any are marked advacned
  # If one is advanced, the whole row should assume to be advanced
  #
  # @param: {Arr} attribute_row_object - array of attributes in a row
  # ---------------

  _hasAdvancedAttribute: (attribute_row_object) ->
    for column_id, attribute of attribute_row_object
      return true if (attribute && attribute.advanced == true)

    return false

  # ---------------
  # Checks all attributes in a row to see if any are ignored
  # If one is ignored, the whole row should assume to be ignored
  #
  # @param: {Arr} attribute_row_object - array of attributes in a row
  # ---------------

  _hasIgnoreAttribute: (attribute_row_object) ->
    for column_id, attribute of attribute_row_object
      return true if (attribute && attribute.ignored == true)

    return false

#-----------  Export  -----------#

module.exports = ProjectSerializer

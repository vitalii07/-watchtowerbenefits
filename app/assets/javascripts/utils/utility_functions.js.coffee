#-----------  Module  -----------#

UtilityFunction =

  # ---------------
  # Determines if column should be used for calculations
  #
  # @param: {Obj} column - column object in question
  # ---------------

  isColumnVisible: (column) ->
    return true if window._RENDER_ALL
    # TODO: integrate different user permissions (ie. admin can see more)
    column = if _.isObject(column) then column else {}
    return if column.state then (column.state == 'finalized') else false

  isRowVisible: (row) ->
    return true if row.sidebar.is_grouping
    return true if !row.sidebar.is_advanced
    rowWithoutSidebar = _.omit(row, "sidebar")

    data = _.map rowWithoutSidebar, (object) -> object.value
    allUnstated = _.isEmpty(_.compact(data))

    if allUnstated
      return false
    else
      return true

  # ---------------
  # Checks if value is numerical and not zero
  #
  # @param: {Int/String} value
  # ---------------

  isUsableNumber: (value) ->
    return _.isNumber(value) && !_.isNaN(value) && (value != 0)

  groupClassNumbers: (numbers) ->
    groups = []
    index = 1
    start = 0
    while index <= numbers.length
      if !numbers[index] || numbers[index] - numbers[index - 1] != 1
        if start == index - 1
          groups.push numbers[start].toString()
        else
          groups.push "#{numbers[start]}-#{numbers[index - 1]}"
        start = index
      index++
    groups.join(', ')

  # ---------------
  # Removes duplicate objects in an array by comparing a specific key
  #
  # @param: {Arr} array_of_objects - array or objects to filter
  # @param: {String} comparison_key - key by which to determine duplicates
  # ---------------

  removeDuplicateObjects: (array_of_objects, comparison_key = 'id') ->
    grouped = _.groupBy(array_of_objects, (obj) -> obj[comparison_key])
    return _.map(grouped, (group) -> group[0])

  # ---------------
  # Formats a numer into a USD-style currency string
  #
  # @param: {Int/Fixed} number - number to format
  # ---------------

   currencyFormater: (number) ->
     decimalplaces     = 2
     decimalcharacter  = '.'
     thousandseparater = ','
     currencyCharacter = '$'

     number    = parseFloat(number)
     sign      = if number < 0 then '-' else ''
     formatted = new String(number.toFixed(decimalplaces))

     if decimalcharacter.length and decimalcharacter != '.'
       formatted = formatted.replace(/\./, decimalcharacter)

     integer   = ''
     fraction  = ''
     strnumber = new String(formatted)
     dotpos    = if decimalcharacter.length then strnumber.indexOf(decimalcharacter) else -1

     if dotpos > -1
       if dotpos
         integer = strnumber.substr(0, dotpos)
       fraction = strnumber.substr(dotpos + 1)
     else
       integer = strnumber
     if integer
       integer = String(Math.abs(integer))

     while fraction.length < decimalplaces
       fraction += '0'

     temparray = new Array

     while integer.length > 3
       temparray.unshift integer.substr(-3)
       integer = integer.substr(0, integer.length - 3)

     temparray.unshift integer
     integer = temparray.join(thousandseparater)
     return sign + currencyCharacter + integer + decimalcharacter + fraction

#-----------  Export  -----------#

module.exports = UtilityFunction

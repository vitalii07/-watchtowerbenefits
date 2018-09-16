exports = module.exports = {}

exports.rateValues = (pc) ->
  financial_cat = _.find(pc.data, (cat) -> cat.name == 'Financial')
  filter = (val) -> val.name.includes('Rate') && !val.name.includes('Rate Basis') && !_.isEmpty(val.value)
  return _.filter(financial_cat.values, filter)

ValueRowString = React.createClass
  propTypes:
    value: React.PropTypes.object.isRequired
    inputValue: React.PropTypes.string
    updateValue: React.PropTypes.func

  render: ->
    value = @props.value
    inputValue = @props.inputValue
    updateValue = @props.updateValue

    return `<tr className='_renewal__table-row'>
      <td>{value.name}</td>
      <td>{value.value}</td>
      <td><input value={inputValue} onChange={function(e) { updateValue(e.target.value) }.bind(this) } /></td>
    </tr>`

module.exports = ValueRowString

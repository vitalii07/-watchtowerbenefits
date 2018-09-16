ToggleSwitch = React.createClass

  propTypes:
    label      : React.PropTypes.string
    onMessage  : React.PropTypes.string
    offMessage : React.PropTypes.string
    isChecked  : React.PropTypes.bool
    onClick    : React.PropTypes.func.isRequired

  getDefaultProps: ->
    return (
      label      : ''
      onMessage  : 'ON'
      offMessage : 'OFF'
      isChecked  : false
    )

  #-----------  HTML Element Render  -----------#

  render: ->
    classes = React.addons.classSet(
      'wt-toggle-switch'     : true
      'wt-toggle-switch--on' : @props.isChecked
    )

    return (
      `<div className={classes} onClick={this.props.onClick}>
        <span className="wt-toggle-switch__label">{this.props.label}</span>
        <div className="wt-toggle-switch__switch">
          <span className="wt-toggle-switch__switch--on">{this.props.onMessage}</span>
          <div className="wt-toggle-switch__switch--block"></div>
          <span className="wt-toggle-switch__switch--off">{this.props.offMessage}</span>
        </div>
      </div>`
    )

#-----------  Export  -----------#

module.exports = ToggleSwitch

#-----------  Requirements  -----------#

# for documentation on the React Modal component see
# http://blog.tryolabs.com/2015/04/13/a-reusable-modal-component-in-react/

ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

#-----------  Modal Class  -----------#

Modal = React.createClass

  propTypes:
    title    : React.PropTypes.string
    canClose : React.PropTypes.bool
    isOpen   : React.PropTypes.bool
    closeModalCallback   : React.PropTypes.func

  getDefaultProps: ->
    return {
      title    : null
      canClose : true
      isOpen   : false
    }

  getInitialState: ->
    return {
      canClose : @props.canClose || true
      isOpen   : @props.isOpen || false
    }

  componentWillReceiveProps: (new_props) ->
    @setState {
      canClose : @props.canClose
      isOpen   : new_props.isOpen
    }

  #-----------  Event Handlers  -----------#

  _closeModal: (evt) ->
    correct_target = ($(evt.target).hasClass('wt-modal__close') || $(evt.target).hasClass('wt-modal'))
    if correct_target && @state.canClose
      @setState { isOpen: false }
      @props.closeModalCallback() if @props.closeModalCallback

  #-----------  HTML Element Render  -----------#

  render: ->
    title_block = (
      `<h2 className="wt-modal__title">{this.props.title}</h2>`
    ) if !_.isEmpty(@props.title)

    close_button = (
      `<i onClick={this._closeModal} className="wt-modal__close icon-close"></i>`
    ) if @state.canClose

    if @state.isOpen
      return (
        `<ReactCSSTransitionGroup transitionName="wt-modal--animation">
            <div className="wt-modal" onClick={this._closeModal}>
              <div className="wt-modal__block" style={this.props.wtModalBlockStyle}>
                {title_block}
                {close_button}
                {this.props.children}
              </div>
            </div>
          </ReactCSSTransitionGroup>`
        )
    else
      return (
        `<ReactCSSTransitionGroup transitionName="wt-modal--animation" />`
      )

#-----------  Export  -----------#

module.exports = Modal

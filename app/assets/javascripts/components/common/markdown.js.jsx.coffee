showdown    = require('showdown')

Markdown = React.createClass
  propTypes:
    source    : React.PropTypes.string.isRequired
    options   : React.PropTypes.object

  getInitialProps: ->
    options: {}

  convertToHtml: ->
    converter   = new showdown.Converter(@props.options)
    html = converter.makeHtml(@props.source || '')
    __html: html

  render: ->
    `<div className="wt-markdown" dangerouslySetInnerHTML={this.convertToHtml()}>
      {this.props.children}
     </div>`

#-----------  Export  -----------#

module.exports = Markdown

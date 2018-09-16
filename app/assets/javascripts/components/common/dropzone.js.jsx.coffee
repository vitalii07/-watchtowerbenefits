# Properties
# url - the url to post to
# postData - any additional data to post (in addition to the files)
# dropzoneComplete - callback for when dropzone upload is done
# dropzoneReady - callback for when dropzone has at least one file to upload
# dropzoneNotReady - callback for when dropzone has zero files to upload

#-----------  React Componet Class  -----------#

DropzoneComponent = React.createClass


  propTypes:
    url              : React.PropTypes.string.isRequired
    postData         : React.PropTypes.object.isRequired
    uploadText       : React.PropTypes.string
    dropzoneReady    : React.PropTypes.func.isRequired
    dropzoneNotReady : React.PropTypes.func.isRequired
    dropzoneComplete : React.PropTypes.func.isRequired

  getDefaultProps: ->
    return { uploadText: 'upload file(s)' }

  getInitialState: () ->
    return { ready: false }

  componentDidMount: () ->
    props = @props
    Dropzone.autoDiscover = false

    options = {
      maxFilesize      : 10 #MB
      parallelUploads  : 10
      uploadMultiple   : true
      acceptedFiles    : "application/pdf,.html,.doc,.docx,.rtf"
      url              : @props.url
      autoProcessQueue : false
      clickable        : $(React.findDOMNode(this)).find(".dz-file-browser-button")[0]
      params           : @props.postData
      headers: {
        "X-CSRF-Token" : $('meta[name="csrf-token"]').attr('content')
      }
    }

    @dropzone = new Dropzone(React.findDOMNode(@), options)

    @dropzone.on "queuecomplete", () ->
      if @getAcceptedFiles().length > 0
        props.dropzoneComplete()

    @dropzone.on "addedfile", (file) ->
      props.dropzoneReady()
      $cancelElement = $("<div class='dz-cancel'></div>")
      $cancelElement.click( =>
        @removeFile(file)
      )
      $(file.previewElement).append($cancelElement)

    @dropzone.on "removedfile", (file) ->
      if @getQueuedFiles().length == 0
        props.dropzoneNotReady()

  componentWillUnmount: () ->
    @dropzone.destroy()

  #-----------  Event Handlers  -----------#

  submit: () ->
    if @dropzone.getAcceptedFiles().length > 0
      @dropzone.processQueue()

  #-----------  HTML Element Render  -----------#`

  render: ->
    return (
      `<div className="wt-dropzone">
        <div className="wt-dropzone__messages" />
        <div className="wt-dropzone__center">
          <img src="data:image/png;base64,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"/>
          <h3 className="h3">Drag & Drop</h3>
          <h6 className="h6">{this.props.uploadText}</h6>
        </div>
        <div className="wt-dropzone__text dz-file-browser-button">or click to select file(s)</div>
      </div>`
    )

#-----------  Export  -----------#

module.exports = DropzoneComponent

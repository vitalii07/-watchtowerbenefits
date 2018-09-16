if typeof(Dropzone) != 'undefined'
  Dropzone.options.dropzone =
    init: ->
      @on "queuecomplete", ->
        window.location = $("form.dropzone").data("redirect-route")
    acceptedFiles: "application/pdf,.html,.doc,.docx"
    autoProcessQueue: false
    maxFilesize: 10 #MB
    parallelUploads: 10
    uploadMultiple: true

$ ->
  $(".dropzone-commit").click ->
    Dropzone.forElement("form.dropzone").processQueue()

#-----------  Requirements  -----------#

LocalStorageAdapter = require('utils/local_storage_adapter')
PersistanceLayer    = require('utils/persistance_layer')

#-----------  Module  -----------#

$ ->

  #-----------  Export XLS  -----------#

  _unarchive_action = '[data-action="unarchive-document"]'

  $(document).on 'click', _unarchive_action, (evt) ->
    document_id = $(evt.target).data('document-id')
    callback = location.reload

    PersistanceLayer.unarchiveColumn(document_id, callback, window.location)

  #-----------  Unarchive Document  -----------#

  _unarchive_action = '[data-action="unarchive-document"]'

  $(document).on 'click', _unarchive_action, (evt) ->
    document_id = $(evt.target).data('document-id')
    callback = location.reload

    PersistanceLayer.unarchiveColumn(document_id, callback, window.location)

  #-----------  Employer Autocomplete  -----------#

  $("input#employer_name").autocomplete({
    minLength: 2
    source: $("#new_project").data("employer-autocomplete")
    focus: (event, ui) ->
      $('input#employer_name').val(ui.item.name)
      false
    select: (event, ui) ->
      $('input#employer_name').val(ui.item.name)
      $('#project_employer_id').val(ui.item.id)
  }).autocomplete( "instance" )._renderItem = ( ul, item ) ->
    $( "<li>" ).append( "<a>#{item.name}</a>" ).appendTo( ul )


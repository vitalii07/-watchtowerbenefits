@distillery =
  init: ->
    @setupOnFocusCallbacks()
    @setupEditCallbacks()
    @setupToggleCallbacks()
    @setupObjectAttributeCallbacks()
    @authenticity_token = $('#document_data').data('authenticity-token')
    # TODO: UPDATE PREVIEW FRAME TO BE A COLLECTION OF PREVIEW FRAMES
    @preview_frames = $('.document_content')
    @setupIframeHighlightListener()
    @setupMarkdownEditor()
    @activeTabIndex = 0

  setupMarkdownEditor: ->
    $(document).ready ->
      $("a.new-contextual-content").trigger("click")

    $(document).on "ajax:beforeSend", "form.contextual-form", (e) ->
      $("#contextual-errors").text('').hide()

    $(document).on "ajax:success", "a.contextual-title, a.new-contextual-content", (e) ->
      new SimpleMDE(element: $(".rich-editable")[0])

  setActiveTabIndex: (index) ->
    @activeTabIndex = index

  setupToggleCallbacks: ->
    $('.collapsable').click ->
      $(this).siblings().toggle()

    toggleCheckbox = document.querySelector('.toggle_required')
    if toggleCheckbox
      toggleIgnoredFields = new Switchery(document.querySelector('.toggle_required'))

      $('.toggle_required').on 'change', ->
        $('.ignored').toggle()

  setupOnFocusCallbacks: ->
    $('.updateable').focus ->
      # Scroll the selector into view if focusing a new or different input
      # IE, don't reset the scroll if they are clicking into the same field as they were previously in
      scrollToPreview =  distillery.lastFocus == undefined || distillery.lastFocus[0] != this
      distillery.showPreview($(this).data('selector'), scrollToPreview)
      distillery.startTimer()
      distillery.lastFocus = $(this)

  setupEditCallbacks: ->
    $('.datepicker').datepicker onSelect: (date) ->
      distillery.updateAttribute $(this), $(this).val()

    $('.updateable:not(.datepicker,:checkbox)').focusout ->
      distillery.updateAttribute $(this), $(this).val()

    $('.updateable:checkbox').change ->
      distillery.updateAttribute $(this), this.checked

    $('.dropdown').change ->
      distillery.updateAttribute $(this), $(this).val()

  setupIframeHighlightListener: ->
    frame = distillery.preview_frames

    getSelection = ->
      selection = frame[distillery.activeTabIndex].contentWindow.document.getSelection()

      if selection.toString().length > 0 && distillery.lastFocus
        text = selection.toString()
        node = selection.getRangeAt(0).commonAncestorContainer
        attributeId = distillery.lastFocus.attr('id')

        selectedRange = selection.getRangeAt(0)

        # node is the entire document!
        if node.nodeType == 3
          newNodeHtml = node.textContent.substring(0, selectedRange.startOffset) +
                        "<span class='highlight' data-attribute-id='#{attributeId}'>" +
                        text +
                        "</span>" +
                        node.textContent.slice(selectedRange.endOffset)

          currentFrame = $('iframe')[distillery.activeTabIndex]
          $(currentFrame).contents().find("span.highlight[data-attribute-id=#{attributeId}]").contents().unwrap()

          $(node).replaceWith(newNodeHtml)
          # what if node = <pre class="taggedDocumentBlock">
          # then node.nodeType == 1
          #
          # should we use selectedRange.surroundContents instead?
        else if node.nodeType == 1
          console.log("selection we need to handle")
          # or check if selectedRange.collapsed ? if it spans multiple containers
          # do we do surroundContents now?
        nodePath = $($('iframe')[distillery.activeTabIndex]).contents().find('span.highlight').getPath() + "[data-attribute-id=#{attributeId}]"
        nodePath = nodePath.replace(/>/g, ' ')

        # update the source document with the updated span tagging
        $.ajax
          url: currentFrame.src
          type: 'PUT'
          dataType: 'json'
          data:
            raw_html: $(currentFrame).contents()[0].documentElement.outerHTML

        distillery.setSelectedText(nodePath, text)

    if frame != undefined && frame.length && frame[0].contentWindow.document.readyState == 'complete' && frame.contents().find("body").children().size() > 0
      frame.contents().find("body").mouseup(getSelection)
    else
      setTimeout(distillery.setupIframeHighlightListener, 100)

  showPreview: (selector, scroll=true) ->
    if @selection
      @selection.css 'background-color', ''

    frame = _.find @preview_frames.contents(), (content) ->
      $(content).find(selector).length

    frameIndex = _.indexOf(@preview_frames.contents(), frame)

    @selection = $(frame).find(selector)
    if @selection.length
      $(window).trigger('distillery:activateTab', frameIndex + 1)

    if @selection.length > 0
      @selection.css 'background-color', 'yellow'
      if scroll
        scrollTo = @selection.offset().top - (window.innerHeight / 3)
        distillery.scrollPreview @selection.offset().top - (window.innerHeight / 3)

  scrollPreview: (position) ->
    # TODO: NEED TO SELECT THE CORRECT PREVIEW FRAME
    @preview_frames.contents().scrollTop position

  setSelectedText: (nodePath, text) ->
    if distillery.lastFocus != undefined
      distillery.lastFocus.val(text)
      console.log(nodePath)
      distillery.lastFocus.data('selector', nodePath)
      distillery.lastFocus.focus()

  updateAttribute: ($input, value) ->
    # Interpret null as empty string
    # If no change between the original and given value, then don't do anything
    originalValue = $input.data('orig-value')
    originalValue = (if _.isNull(originalValue) || _.isUndefined(originalValue) then "" else originalValue)
    value = (if _.isNull(value) || _.isUndefined(value) then "" else value)

    return if value.toString() == originalValue.toString()

    $parent = $input.closest('.attribute_container')
    path = $parent.data('update-path')
    data =
      authenticity_token: distillery.authenticity_token
      metadata: time: distillery.endTimer()
      selector: $input.data('selector') if $input.data('selector') != null
      column_name: $input.data('column-name')

    if $input.data('is-attribute')
      data.attribute_id = $input.attr('name')
      if $input.data('sub-attribute')
        new_val = {}
        new_val[$input.data('sub-attribute')] = value
        data.attribute_value = new_val
      else
        data.attribute_value = value
    else
      data[$parent.data('type')] = {}
      data[$parent.data('type')][$input.attr('name')] = value

    $.ajax
      url: path
      type: 'PUT'
      data: data
      success: (result) ->
        $input.data 'orig-value', value
        distillery.flashTableRowFromInput $input, 'success'
      error: (result) ->
        distillery.flashTableRowFromInput $input, 'failure'

  flashTableRowFromInput: ($input, klass) ->
    $row = $input.closest('tr')
    $row.addClass klass
    setTimeout (->
      $row.removeClass klass
    ), 250

  setupObjectAttributeCallbacks: () ->
    $('.object_attribute').change ->
      data = {}
      data[$(this).data('type')] = {}
      value = if this.type == "checkbox" then this.checked else $(this).val()
      data[$(this).data('type')][$(this).data('attribute')] = value
      needsRefresh = $(this).data('refresh')
      $.ajax
        url: $(this).data('update-url')
        type: 'PUT'
        data: data
        dataType: "json"
        complete: (jqXHR, textStatus) ->
          if needsRefresh
            location.reload()
        error: (jqXHR, textStatus, errorThrown) ->
          # Error, eh, don't do anything

  timer: null
  startTimer: ->
    if @timer == null
      @timer = (new Date).getTime()

  endTimer: ->
    @.startTimer() if @timer == null
    endTime = (new Date).getTime()
    elapsedTime = endTime - (@timer)
    @timer = endTime
    elapsedTime

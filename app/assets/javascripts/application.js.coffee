# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery-ui
#= require jquery_ujs
#
#= require_tree ./shared
#
#= require react
#= require react_ujs
#= require components
#= require switchery/switchery
#= require simplemde/simplemde.min
#
#= require_self

$ ->

  #-----------  Retractible Sidebar  -----------#

  _sidebar_wrapper = '.wt-page-content'
  _toggle_sidebar  = '[data-action="toggle-sidebar"]'
  _hide_sidebar    = '[data-action="hide-sidebar"]'

  $(document).on 'click', _toggle_sidebar, (evt) ->
    $(window).trigger('sidebar:toggle')

  $(document).on 'click', _hide_sidebar, (evt) ->
    $(window).trigger('sidebar:toggle')

  $(window).on 'sidebar:toggle', ->
    if $(_toggle_sidebar).hasClass('selected')
      new_text = $(_toggle_sidebar).html().replace(/Hide/g, 'View')
      $(_toggle_sidebar).removeClass('selected').html(new_text)
      $(_sidebar_wrapper).removeClass('has-sidebar')
    else
      new_text = $(_toggle_sidebar).html().replace(/View/g, 'Hide')
      $(_toggle_sidebar).addClass('selected').html(new_text)
      $(_sidebar_wrapper).addClass('has-sidebar')

  #-----------  Flash Messages  -----------#

  _flash_wrapper = '.wt-flash-messages'
  _flash_close   = '.wt-flash-messagee__close'

  $(document).on 'click', _flash_close, (evt) ->
    $(_flash_wrapper).fadeOut(250)

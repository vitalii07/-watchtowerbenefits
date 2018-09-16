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
#= require_tree ./admin
#= require chosen.jquery.min
#= require_self

$ ->
  distillery.init()

  $('select#copy-product-list').chosen({
    no_results_tex: "No products found.",
    width: "20%"
  })

  $('#source_id').on 'change', (event) ->
    products = $.get("/api/v1/documents/#{event.target.value}/products")
    $productList = $('#copy-product-list')

    products.fail ->
      # clear the list
      $productList.empty()
      # update chosen
      $productList.trigger('chosen:updated')

    products.done (products) ->
      productMap = {}

      # build option list for product select box
      for product in products
        productMap[product.product_type_name] = product.id


      # clear current product list select box
      $productList.empty()

      # update product list select with new options
      $.each productMap, (key, value) ->
        $newOption = $("<option></option>").attr("value", value).text(key)
        console.log($newOption)
        $productList.append($newOption)

      # update chosen
      $productList.trigger('chosen:updated')

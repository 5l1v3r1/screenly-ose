
@screenly = window.screenly ? {}
@screenly.collections = window.screenly.collections ? {}
@screenly.views = window.screenly.views ? {}

jQuery ->

  ################################
  # Models
  ################################

  class Asset extends Backbone.Model

  ################################
  # Collections
  ################################

  class Assets extends Backbone.Collection
    url: "/api/assets"
    model: Asset
    
    initialize: (options) ->
      @on "reset", ->
        screenly.ActiveAssets.reset()
        screenly.InactiveAssets.reset()

        @each (model) ->
          if model.get('is_active')
            screenly.ActiveAssets.add model
          else
            screenly.InactiveAssets.add model

  (screenly.Assets = new Assets()).fetch()

  class ActiveAssets extends Backbone.Collection
    model: Asset

  class InactiveAssets extends Backbone.Collection
    model: Asset

  screenly.collections.Assets = Assets
  screenly.collections.ActiveAssets = ActiveAssets
  screenly.collections.InactiveAssets = InactiveAssets

  screenly.ActiveAssets = new ActiveAssets()
  screenly.InactiveAssets = new InactiveAssets()

  ################################
  # Views
  ################################

  class AddAssetModalView extends Backbone.View
    initialize: (options) ->
      @template = _.template($('#add-asset-modal-template').html())

    render: ->
      $(@el).html(@template())
      @

  screenly.views.AddAssetModalView = AddAssetModalView

  class EditAssetModalView extends Backbone.View

  class AssetsView extends Backbone.View
    initialize: (options) ->

      if not 'template_name' in options
        console.log "You need to specify the template name for this AssetsView."

      if not 'childViewClass' in options
        console.log "You must specify the child view class for this AssetsView."

      @template = _.template($('#' + options.template_name).html())
      
      @collection.bind "reset", @render, @
      @collection.bind "remove", @render, @
      @collection.bind "add", @render, @

    render: ->
      $(@el).html(@template())

      # TODO This can be cleaned up to not re-render everything all the time.
      
      @$('tbody').empty()
      @collection.each (asset) =>
        @$('tbody').append (new @options['childViewClass']({model: asset})).render().el

      @

  class ActiveAssetRowView extends Backbone.View

    initialize: (options) ->
      @template = _.template($('#active-asset-row-template').html())

    events:
      'click #deactivate': 'deactivateAsset'

    tagName: "tr"

    render: ->
      $(@el).html(@template(@model.toJSON()))
      @

    deactivateAsset: (event) ->
      event.preventDefault()
      screenly.ActiveAssets.remove(@model)
      screenly.InactiveAssets.add(@model)


  class InactiveAssetRowView extends Backbone.View

    initialize: (options) ->
      @template = _.template($('#inactive-asset-row-template').html())

    events:
      'click #activate': 'activateAsset'

    tagName: "tr"

    render: ->
      $(@el).html(@template(@model.toJSON()))
      @

    activateAsset: (event) ->
      event.preventDefault()
      screenly.InactiveAssets.remove @model
      screenly.ActiveAssets.add @model

  screenly.views.AssetsView = AssetsView
  screenly.views.ActiveAssetRowView = ActiveAssetRowView

  # Initialize the initial view
  activeAssetsView = new AssetsView(
    collection: screenly.ActiveAssets, 
    template_name: "active-assets-template", 
    childViewClass: ActiveAssetRowView
  )

  inactiveAssetsView = new AssetsView(
    collection: screenly.InactiveAssets,
    template_name: "inactive-assets-template",
    childViewClass: InactiveAssetRowView
  )

  $("#active-assets-container").append activeAssetsView.render().el
  $("#inactive-assets-container").append inactiveAssetsView.render().el

  $("#add-asset-button").click ->
    console.log "Clicked add asset button"
    modal = new AddAssetModalView()
    $("body").append modal.render().el
    $(modal.el).children(":first").modal()




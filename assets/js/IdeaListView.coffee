jQuery ->

  class IdeaItem extends Backbone.Model

    url: '/ideas',

    _methodToUrl:
      'read': '/ideas/get'
      'create': '/ideas/create'
      'update': '/ideas/update'
      'delete': '/ideas/delete'

    initialize: (count) ->
      @_listTypeEnum = ['unspecified', 'art/gallery', 'philanthropy', 'productivity']
      @set 'count', count

    defaults:
      listType: 'unspecified'
      body: ''
      likes: 0
      urlsReplaced: false

    setListType: (listType) ->
      if listType in @_listTypeEnum
        @set 'listType', listType
      else
        throw new Error 'Invalid listType selected.'

    setBody: (body) ->
      body = body.trim()
      if body.length < 1
        $('.form-error').text 'Empty ideas not allowed!'
                        .removeClass 'hidden'
        throw new Error 'Invalid body length'
      else
        @set 'body', body

    sync: (method, model, options) ->
      options = if options then options else {}
      options.url = model._methodToUrl[method.toLowerCase()]
      Backbone.sync method, model, options


  class IdeaItemList extends Backbone.Collection

    url: '/ideas'
    model: IdeaItem
    @bodyFilterText = ''

    initialize: ->
      @fetch()

    filterByBody: (text) ->
      @bodyFilterText = text.toLowerCase()
      filteredList = @models.filter @_filterByBodyPredicate
      new IdeaItemList filteredList

    _filterByBodyPredicate: (model) =>
      return model.get('body').toLowerCase().indexOf(@bodyFilterText) > -1


  class IdeaItemView extends Backbone.View

    tagName: 'li'
    className: 'idea-item'

    initialize: ->
      _.bindAll @, 'render'
      @regex = new RegExp /\b(?:https?|ftp):\/\/[a-z0-9-+&@#\/%?=~_|!:,.;]*[a-z0-9-+&@#\/%=~_|]/gim
      @pseudoRegex = new RegExp /(^|[^\/])(www\.[\S]+(\b|$))/gim

    render: ->
      @_gentrifyModel()
      $(@el).html "<p class='idea-item-link'><a href='/ideas/#{@model.get 'id'}' target='_blank'>##{@model.get 'id'}</a>" +
                  "<span class='item-meta item-likes'><a href='#' class='item-like-button'>LIKES:</a> #{@model.get 'likes'}</span></p>" +
                  "<p class='idea-item-header'><span class='item-datetime item-meta'>#{@model.get 'datetime'}</span>" +
                  "<span class='item-meta item-type item-type-#{@model.get 'listType'}'>#{@model.get 'listType'}</span></p>" +
                  "<p class='idea-item-body'>#{@model.get 'body'}</p>"
      @

    _gentrifyModel: ->
      if moment(@model.get('datetime')).isValid()
        @model.set 'datetime', new moment(@model.get('datetime')).calendar()
      if not @model.get 'urlsReplaced'
        @model.set('body', @model.get('body')
          .replace(@regex, '<a target="_blank" href="$&">$&</a>')
          .replace @pseudoRegex, '$1<a target="_blank" href="http://$2">$2</a>')
        @model.set 'urlsReplaced', true

    likeItem: ->
      @model.set 'likes', @model.get 'likes' + 1
      @model.save()

    events:
      'click .item-like-button': 'likeItem'


  class IdeaListView extends Backbone.View

    el: $ 'body'

    initialize: ->
      _.bindAll @, 'render', 'addItem', 'appendItem'
      @count = 0
      @collection = new IdeaItemList
      @collection.bind 'add', @appendItem
      @selectedTypeClassName = 'idea-type-selected'
      @render()

    render: ->
      $(@el).append '<ul class="idea-list"></ul>'

    addItem: ->
      item = new IdeaItem
      try
        item.setListType $('.' + @selectedTypeClassName).attr 'data-idea-type'
      catch e
        console.log e
        alert 'Please select a valid idea type.'
        return false
      try
        item.setBody $('.idea-input').val()
      catch e
        console.log e
        return false
      item.save null, { success: @_onSaveSuccess, error: @_onSaveError }

    appendItem: (item) ->
      ideaItemView = new IdeaItemView model: item
      $('.idea-list').prepend ideaItemView.render().el

    selectIdeaType: (evt, target) ->
      $('.idea-type').removeClass @selectedTypeClassName
      $(evt.currentTarget).addClass @selectedTypeClassName

    addItemOnEnterPressed: (evt) ->
      if evt.keyCode is 13
        @addItem()

    filterByBody: (evt) ->
      filteredList = @collection.filterByBody evt.target.value
      $('.idea-item').addClass 'hidden'
      for item in filteredList.models
        @appendItem item
      $('.idea-item.hidden').remove()

    _onSaveSuccess: (model, response) =>
      @collection.add model
      @_resetForm()

    _onSaveError: (model, response) ->
      alert 'Failed to add item :( Refresh and try again.'

    _resetForm: ->
      $('.idea-type').removeClass @selectedTypeClassName
      $('.idea-type-gray').addClass @selectedTypeClassName
      $('.idea-input').val ''
      $('.form-error').addClass 'hidden'

    events:
      'click .idea-submit-button': 'addItem'
      'click .idea-type': 'selectIdeaType'
      'keyup .idea-input': 'addItemOnEnterPressed'
      'keyup .idea-filter-input': 'filterByBody'

  ideaListView = new IdeaListView
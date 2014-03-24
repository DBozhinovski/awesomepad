class DocumentEditorView extends Views.BaseView
  constructor: ->
    super $("#canvas"), (doc = false) =>
      output = "
        <label>title</label>
        <input type='text' name='title' />

        <label>content</label>
        <div name='content'></div>

        <label>category</label>
        <select name='category'></select><button class='add' data-action='add-category'>+</button>

        <div class='actions'>
          <button data-action='save'>save</button>
          <button data-action='close'>cancel</button>
        </div>
      "

      $output = $("<div>")
      $output.html(output)

      $output.find("[name=content]").summernote {
        height: 400
      }

      if doc
        $output.find("input[name='title']").val doc.title
        $output.find("[name='content']").code doc.content
        $output.find("[name='category']").val doc.category
        @id = doc.id
        @mode = 'update'
        output = $output
      else
        @mode = 'create'

      $output

  render: (doc) ->
    super doc
    categories = new Models.CategoryModel().all()
    for id of categories
      $("select[name='category']").append("<option>#{categories[id].title}</option")
    @bind()

  close: ->
    @element.find('button').off 'click'
    Router.call "documents"

  bind: ->
    @element.find('button').on 'click', (event) =>
      target = $ event.currentTarget
      action = target.attr 'data-action'

      switch action
        when "save"
          record = 
            title: @element.find("input[name='title']").val()
            content: @element.find("[name='content']").code()
            category: @element.find("[name='category']").val()

          if @mode is 'update'
            record.id = @id
            EventEmitter.trigger 'document:update', record
          else
            EventEmitter.trigger 'document:store', record

          if @categoryMode is 'add'
            EventEmitter.trigger 'category:store', { title: record.category }

          @close()
          alert "Document saved"
        when "add-category"
          select = $("select[name='category']")
          textbox = $("<input name='category' />")

          select.replaceWith textbox
          $("button[data-action='add-category']").remove()
          @categoryMode = 'add'
        when "close"
          @close()

Views.DocumentEditorView = DocumentEditorView
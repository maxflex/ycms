Vue.config.devtools = true
$(document).ready ->
    # вешеаем событие по клику по кнопке
    $('#searchModalOpen').click ->
        $('#searchModal').modal({keyboard: true})
        delayFunction = ->
            $('#searchQueryInput').focus()
        setTimeout delayFunction, 500
        $($('body.modal-open .row')[0]).addClass('blur')
        false
    $('#searchModal')
        .on 'hidden.bs.modal', ->
            delayFnc = ->
                $('.blur')
                    .removeClass 'blur'
            setTimeout delayFnc, 500

    # компонент поиска
    viewVue = new Vue
        el: '#searchModal'
        data:
            lists: []
            links: {}
            results: -1
            active: 0
            query: ''
            oldquery: ''
            all: 0
            loading: false
        methods:
            loadData:    _.debounce ->
                this.$http.post 'api/search', {query: this.query}
                    .then (success) =>
                        this.loading = false
                        this.active = 0
                        this.all = 0
                        this.lists = []
                        if success.body.results > 0
                            this.results = success.body.results
                            if success.body.variables.length > 0
                                for item, i in success.body.variables
                                    console.log(item)
                                    item.type = 'variable'
                                    this.all++
                                    this.links[this.all] = 'variables/' + item.id + '/edit'
                                    item.link = this.links[this.all]
                                    this.lists.push(item)
                            if success.body.pages.length > 0
                                for item, i in success.body.pages
                                    item.type = 'page'
                                    this.all++
                                    this.links[this.all] = 'pages/' + item.id + '/edit'
                                    item.link = this.links[this.all]
                                    this.lists.push(item)
                        else
                          this.active = 0
                          this.all = 0
                          this.lists = []
                          this.results = 0
                    , (error) =>
                        this.active = 0
                        this.all = 0
                        this.lists = []
                        this.results = 0
            , 150

            # метод скролит по необходимости до нужной части результата поиска
            scroll: ->
                $('#searchResult').scrollTop((this.active - 4) * 30)

            getStateClass: (state) ->
                obj = {}
                obj["tutor-state-#{state}"] = true
                obj

            # обработка события набора текста
            keyup: (e) ->
                if e.code == 'ArrowUp'
                    e.preventDefault();
                    if this.active > 0
                        this.active--
                    this.scroll()
                else if e.code == 'ArrowDown'
                    e.preventDefault();
                    if this.active < this.results
                        this.active++
                    if this.active > 4
                        this.scroll()
                else if e.code == 'Enter' and this.active > 0
                    url = this.links[this.active]
                    window.location = url
                else
                    if this.query isnt ''
                        if this.oldquery != this.query and this.query.length > 2
                            # this.loading = true
                            this.loadData()
                        this.oldquery = this.query
                    else
                        this.active = 0
                        this.all = 0
                        this.lists = []
                        this.results = -1
                    #console.log this.lists
                null
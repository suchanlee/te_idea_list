exports.index = (req, res) ->
    res.render 'index'

exports.get = (req, res) ->
    console.log 'get'
    res.render 'idea'
Idea = require '../models/idea'

# Idea model's CRUD controller.
module.exports =

  # Lists all ideas
  index: (req, res) ->
    Idea.find {}, (err, ideas) ->
      res.send ideas

  # Creates new idea with data from `req.body`
  create: (req, res) ->
    idea = new Idea req.body
    idea.save (err, idea) ->
      if not err
        res.send idea
        res.statusCode = 201
      else
        res.send err
        res.statusCode = 500

  # Gets idea by id
  get: (req, res) ->
    Idea.findById req.params.id, (err, idea) ->
      if not err
        res.send idea
      else
        res.send err
        res.statusCode = 500

  # Updates idea with data from `req.body`
  update: (req, res) ->
    Idea.findByIdAndUpdate req.params.id, {"$set":req.body}, (err, idea) ->
      if not err
        res.send idea
      else
        res.send err
        res.statusCode = 500

  # Deletes idea by id
  delete: (req, res) ->
    Idea.findByIdAndRemove req.params.id, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500


mongoose = require 'mongoose'
autoIncrement = require 'mongoose-auto-increment'

connection = mongoose.createConnection 'mongodb://localhost/example'

autoIncrement.initialize(connection)

# Idea model
Idea = new mongoose.Schema(
  listType: {
    type: String,
    enum: [
      'unspecified',
      'art/gallery',
      'philanthropy',
      'productivity'
    ]
  }
  body: String
  # likes: {
  #   type: Number,
  #   default: 0
  # }
  datetime: {
    type: Date,
    default: Date.now
  }
)

Idea.plugin autoIncrement.plugin, {
  model: 'Idea',
  field: 'id',
  startAt: 1
}

module.exports = mongoose.model 'Idea', Idea
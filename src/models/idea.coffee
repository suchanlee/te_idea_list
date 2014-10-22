mongoose = require 'mongoose'

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
  datetime: {
    type: Date,
    default: Date.now
  }
)

module.exports = mongoose.model 'Idea', Idea
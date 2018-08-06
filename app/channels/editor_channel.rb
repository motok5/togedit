class EditorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "editor_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def write(data)
    ActionCable.server.broadcast 'editor_channel', text: data['text']
  end
end

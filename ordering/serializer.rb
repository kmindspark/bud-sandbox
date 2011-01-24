require 'rubygems'
require 'bud'

module SerializerProto
  def state
    super
    interface input, :enqueue, ['ident'], ['payload']
    interface output, :dequeue, [], ['reqid']
    interface output, :dequeue_resp, ['reqid'], ['ident', 'payload']
  end
end

module Serializer
  include SerializerProto
  include Anise
  annotator :declare

  def state
    super
    table :storage, ['ident', 'payload']
    scratch :top, ['ident']
  end

  declare 
  def logic
    storage <= enqueue
    top <= storage.group(nil, min(storage.ident))
  end

  declare
  def actions
    deq = join [storage, top, dequeue], [storage.ident, top.ident]
    dequeue_resp <+ deq.map do |s, t, d|
      [d.reqid, s.ident, s.payload]
    end
    storage <- deq.map {|s, t, d| s }
  end
end

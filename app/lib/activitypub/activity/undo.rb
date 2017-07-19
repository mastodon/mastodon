# frozen_string_literal: true

class ActivityPub::Activity::Undo < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Announce'
      undo_announce
    when 'Follow'
      undo_follow
    when 'Like'
      undo_like
    when 'Block'
      undo_block
    end
  end

  private

  def undo_announce
    raise NotImplementedError
  end

  def undo_follow
    raise NotImplementedError
  end

  def undo_like
    raise NotImplementedError
  end

  def undo_block
    raise NotImplementedError
  end
end

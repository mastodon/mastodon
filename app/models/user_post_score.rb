# frozen_string_literal: true

# == Schema Information
#
# Table name: user_post_scores
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  status_id  :bigint(8)        not null
#  score      :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_post_scores_on_user_id_and_status_id  (user_id,status_id) UNIQUE
#  index_user_post_scores_on_status_id              (status_id)
#
class UserPostScore < ApplicationRecord
  belongs_to :user, class_name: 'Account'
  belongs_to :status

  validates :user_id, presence: true
  validates :status_id, presence: true
  validates :score, presence: true
  validates :user_id, uniqueness: { scope: :status_id }

  # Convert a hash of scores from the scoring service to UserPostScore objects
  # @param scores [Hash<Integer, Hash<Integer, Float>>] Hash mapping status_id -> user_id -> score
  # @return [Array<UserPostScore>] Array of UserPostScore objects
  def self.from_score_hash(scores)
    scores.flat_map do |status_id, user_scores|
      user_scores.map do |user_id, score|
        new(
          status_id: status_id,
          user_id: user_id,
          score: score
        )
      end
    end
  end

  # Convert an array of UserPostScore objects to the hash format expected by the feed manager
  # @param scores [Array<UserPostScore>] Array of UserPostScore objects
  # @return [Hash<Integer, Hash<Integer, Float>>] Hash mapping status_id -> user_id -> score
  def self.to_score_hash(scores)
    scores.each_with_object({}) do |score, hash|
      hash[score.status_id] ||= {}
      hash[score.status_id][score.user_id] = score.score
    end
  end
end 
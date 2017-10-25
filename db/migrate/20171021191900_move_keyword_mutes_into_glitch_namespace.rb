class MoveKeywordMutesIntoGlitchNamespace < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      rename_table :keyword_mutes, :glitch_keyword_mutes
    end
  end
end

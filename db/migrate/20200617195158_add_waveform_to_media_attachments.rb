class AddWaveformToMediaAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :media_attachments, :waveform, :text
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  controller do
    include ObfuscateFilename

    obfuscate_filename :file

    def file
      render plain: params[:file]&.original_filename
    end
  end

  before do
    routes.draw { get 'file' => 'anonymous#file' }
  end

  it 'obfusticates filename if the given parameter is specified' do
    file = fixture_file_upload('files/imports.txt', 'text/plain')
    post 'file', params: { file: file }
    expect(response.body).to end_with '.txt'
    expect(response.body).not_to include 'imports'
  end

  it 'does nothing if the given parameter is not specified' do
    post 'file'
  end
end

# frozen_string_literal: true

class Custom::RegistrationsController < Devise::RegistrationsController
  def new
    super do |resource|
      @new_block_called = true
    end
  end

  def create
    super do |resource|
      @create_block_called = true
    end
  end

  def update
    super do |resource|
      @update_block_called = true
    end
  end

  def create_block_called?
    @create_block_called == true
  end

  def update_block_called?
    @update_block_called == true
  end

  def new_block_called?
    @new_block_called == true
  end
end

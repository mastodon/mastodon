# frozen_string_literal: true

module StatusControllerConcern
  extend ActiveSupport::Concern

  ANCESTORS_LIMIT         = 40
  DESCENDANTS_LIMIT       = 60
  DESCENDANTS_DEPTH_LIMIT = 20

  def create_descendant_thread(starting_depth, statuses)
    depth = starting_depth + statuses.size

    if depth < DESCENDANTS_DEPTH_LIMIT
      {
        statuses: statuses,
        starting_depth: starting_depth,
      }
    else
      next_status = statuses.pop

      {
        statuses: statuses,
        starting_depth: starting_depth,
        next_status: next_status,
      }
    end
  end

  def set_ancestors
    @ancestors     = @status.reply? ? cache_collection(@status.ancestors(ANCESTORS_LIMIT, current_account), Status) : []
    @next_ancestor = @ancestors.size < ANCESTORS_LIMIT ? nil : @ancestors.shift
  end

  def set_descendants
    @max_descendant_thread_id   = params[:max_descendant_thread_id]&.to_i
    @since_descendant_thread_id = params[:since_descendant_thread_id]&.to_i

    descendants = cache_collection(
      @status.descendants(
        DESCENDANTS_LIMIT,
        current_account,
        @max_descendant_thread_id,
        @since_descendant_thread_id,
        DESCENDANTS_DEPTH_LIMIT
      ),
      Status
    )

    @descendant_threads = []

    if descendants.present?
      statuses       = [descendants.first]
      starting_depth = 0

      descendants.drop(1).each_with_index do |descendant, index|
        if descendants[index].id == descendant.in_reply_to_id
          statuses << descendant
        else
          @descendant_threads << create_descendant_thread(starting_depth, statuses)

          # The thread is broken, assume it's a reply to the root status
          starting_depth = 0

          # ... unless we can find its ancestor in one of the already-processed threads
          @descendant_threads.reverse_each do |descendant_thread|
            statuses = descendant_thread[:statuses]

            index = statuses.find_index do |thread_status|
              thread_status.id == descendant.in_reply_to_id
            end

            if index.present?
              starting_depth = descendant_thread[:starting_depth] + index + 1
              break
            end
          end

          statuses = [descendant]
        end
      end

      @descendant_threads << create_descendant_thread(starting_depth, statuses)
    end

    @max_descendant_thread_id = @descendant_threads.pop[:statuses].first.id if descendants.size >= DESCENDANTS_LIMIT
  end
end

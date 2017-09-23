# frozen_string_literal: true

class EnqueteResultTootWorker
  include Sidekiq::Worker

  def perform(status_id)
    status = Status.find(status_id)
    return unless status

    enquete_info = JSON.parse(status.enquete)
    return unless enquete_info

    vote_sum = 0
    counts = []
    enquete_info['items'].each_with_index do |_item, i|
      counts.push(redis.get("enquete:status:#{status_id}:item_index:#{i}").to_i)
      vote_sum += redis.get("enquete:status:#{status_id}:item_index:#{i}").to_i
    end
    ratios = counts.map do |item|
      if vote_sum.zero?
        item
      else
        (((item.to_f / vote_sum) * 100).round * 2).ceil(-1) / 2
      end
    end

    ratios_text = append_prefix_rate(ratios)
    enquete_info['ratios'] = ratios
    enquete_info['ratios_text'] = ratios_text
    enquete_info['type'] = 'enquete_result'
    enquete_json = JSON.generate(enquete_info)
    result_status_text = build_enquete_result_status(enquete_info['question'], enquete_info['items'], ratios, ratios_text)

    @status = PostStatusService.new.call(status.account,
                                         result_status_text,
                                         status,
                                         sensitive: status.sensitive,
                                         spoiler_text: status.spoiler_text,
                                         visibility: status.visibility,
                                         application: status.application,
                                         enquete: enquete_json)
  rescue ActiveRecord::RecordNotFound
    true
  end

  def build_enquete_result_status(question, items, ratios, ratios_text)
    question_frame = "\n━━━━━━━━━━━━\n"
    status = 'knzk.me  アンケート(結果)' + question_frame + question + question_frame
    ratios.each_with_index do |rate, i|
      if i == ratios.length - 1
        branch_mark = '└'
        pipe_mark = '　'
      else
        branch_mark = '├'
        pipe_mark = '｜'
      end
      status += branch_mark + " #{i + 1}.#{items[i]}\n"
      status += pipe_mark + " #{rate_to_graph(rate)} #{ratios_text[i]}\n"
    end
    status
  end

  def redis
    Redis.current
  end

  def rate_to_graph(rate)
    division = 5
    rate_mark = '■'
    blank_mark = '□'
    rate_num_5_grade = ((rate / 2).round(-1) * 2) / 20
    rate_mark * rate_num_5_grade + blank_mark * (division - rate_num_5_grade)
  end

  def append_prefix_rate(ratios)
    postfix = %w(ぐらい ちょっと ほど)
    rand_num = rand(postfix.length)
    ratios_text = []

    ratios.each_with_index do |rate, _i|
      rate_s = rate.to_s + '%'
      ratios_text.push(rate_s + postfix[rand_num])
    end
    ratios_text
  end
end
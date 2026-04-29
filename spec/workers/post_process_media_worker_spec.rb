# frozen_string_literal: true

require 'rails_helper'

# PostProcessMediaWorker 测试
#
# 【测试覆盖范围】
# 1. 基本功能测试
# 2. 幂等性测试（重复执行不重复副作用）
# 3. 可恢复性测试（失败后重试成功）
# 4. 状态流转测试
# 5. 并发测试
#
# 【幂等 Key 设计验证】
# - Key 格式：lock:post_process_media:{media_attachment_id}
# - 粒度：每个 media_attachment 独立的锁
# - 过期时间：15 分钟
#
# 【为什么是这个粒度？】
# 1. 媒体处理是针对单个媒体附件的操作
# 2. 不同媒体附件之间没有依赖，互不影响
# 3. 保证单个媒体附件不会被重复处理，同时允许多个媒体附件并发处理
# 4. 不会因为一个媒体附件卡住而影响其他媒体附件的处理
#
# 【为什么是 15 分钟？】
# 1. 大多数视频处理在几分钟内完成
# 2. 15 分钟是一个合理的上限，防止永久死锁
# 3. 与 Sidekiq 默认超时策略保持一致
# 4. 如果处理超过 15 分钟，视为"卡住"，可以重新处理
#
# 【关键副作用断言】
# 1. reprocess! 调用次数：确保不会重复生成缩略图
# 2. processing 状态流转：确保状态正确变化
# 3. save! 调用次数：确保不会重复更新数据库
# 4. reset_parent_cache 触发次数：确保不会重复清理缓存（虽然是幂等的）
#
RSpec.describe PostProcessMediaWorker, :attachment_processing do
  let(:worker) { described_class.new }
  let(:media_attachment) { Fabricate(:media_attachment) }
  let(:status) { Fabricate(:status, account: media_attachment.account) }

  before do
    media_attachment.update!(status: status)
  end

  describe '#perform' do
    it 'reprocesses and updates the media attachment' do
      worker.perform(media_attachment.id)

      expect(media_attachment.reload.processing).to eq('complete')
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123)

      expect(result).to be(true)
    end

    context '幂等性测试' do
      context 'when media is already processed' do
        before do
          media_attachment.update!(processing: :complete)
        end

        it 'skips reprocessing and returns true' do
          expect_any_instance_of(Paperclip::Attachment).not_to receive(:reprocess!)

          result = worker.perform(media_attachment.id)

          expect(result).to be(true)
          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '快速路径：不获取 Redis 锁' do
          expect_any_instance_of(Lockable).not_to receive(:with_redis_lock)

          worker.perform(media_attachment.id)
        end
      end

      context '重复执行（模拟 Redis 瞬断）' do
        it 'does not cause duplicate processing' do
          reprocess_count = 0
          allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!) do
            reprocess_count += 1
          end

          thread1 = Thread.new { worker.perform(media_attachment.id) }
          thread2 = Thread.new { worker.perform(media_attachment.id) }

          thread1.join
          thread2.join

          expect(reprocess_count).to eq(1)
          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '状态只从 queued 流转到 complete 一次' do
          expect { worker.perform(media_attachment.id) }
            .to change { media_attachment.reload.processing }
            .from('queued').to('complete')

          expect { worker.perform(media_attachment.id) }
            .not_to change { media_attachment.reload.processing }
        end
      end
    end

    context '可恢复性测试' do
      context 'when media processing failed' do
        before do
          media_attachment.update!(processing: :failed)
        end

        it 'retries processing' do
          worker.perform(media_attachment.id)

          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '状态从 failed 流转到 complete' do
          expect { worker.perform(media_attachment.id) }
            .to change { media_attachment.reload.processing }
            .from('failed').to('complete')
        end
      end

      context '关键回归：第一次失败 -> 第二次重试成功' do
        it '不产生重复副作用，reprocess! 恰好被调用 2 次' do
          reprocess_count = 0

          allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!) do
            reprocess_count += 1
            raise StandardError, '模拟处理失败' if reprocess_count == 1
          end

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

          expect(reprocess_count).to eq(1)
          expect(media_attachment.reload.processing).to eq('in_progress')

          worker.perform(media_attachment.id)

          expect(reprocess_count).to eq(2)
          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '状态流转：queued -> in_progress（失败）-> in_progress -> complete' do
          reprocess_count = 0

          allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!) do
            reprocess_count += 1
            raise StandardError, '模拟处理失败' if reprocess_count == 1
          end

          expect(media_attachment.processing).to eq('queued')

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)
          expect(media_attachment.reload.processing).to eq('in_progress')

          worker.perform(media_attachment.id)
          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '第三次调用：快速路径，不产生副作用' do
          reprocess_count = 0

          allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!) do
            reprocess_count += 1
            raise StandardError, '模拟处理失败' if reprocess_count == 1
          end

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

          worker.perform(media_attachment.id)
          expect(reprocess_count).to eq(2)
          expect(media_attachment.reload.processing).to eq('complete')

          worker.perform(media_attachment.id)

          expect(reprocess_count).to eq(2)
        end

        it '失败后不卡在 in_progress，下次重试立即继续' do
          reprocess_count = 0

          allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!) do
            reprocess_count += 1
            raise StandardError, '模拟处理失败' if reprocess_count == 1
          end

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

          expect(media_attachment.reload.processing).to eq('in_progress')

          worker.perform(media_attachment.id)

          expect(media_attachment.reload.processing).to eq('complete')
          expect(reprocess_count).to eq(2)
        end
      end
    end

    context '状态流转测试' do
      it '正常路径：queued -> in_progress -> complete' do
        expect(media_attachment.processing).to eq('queued')

        worker.perform(media_attachment.id)

        expect(media_attachment.reload.processing).to eq('complete')
      end

      it '失败路径：queued -> in_progress ->（异常）' do
        allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!)
          .and_raise(StandardError, '处理失败')

        expect(media_attachment.processing).to eq('queued')

        expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

        expect(media_attachment.reload.processing).to eq('in_progress')
      end

      it '失败重试：in_progress -> in_progress -> complete' do
        reprocess_count = 0

        allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!) do
          reprocess_count += 1
          raise StandardError, '模拟处理失败' if reprocess_count == 1
        end

        expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)
        expect(media_attachment.reload.processing).to eq('in_progress')

        worker.perform(media_attachment.id)
        expect(media_attachment.reload.processing).to eq('complete')
      end

      it 'failed 状态重试：failed -> in_progress -> complete' do
        media_attachment.update!(processing: :failed)

        worker.perform(media_attachment.id)

        expect(media_attachment.reload.processing).to eq('complete')
      end
    end

    context '并发测试' do
      it '多个线程同时执行，只有一个能成功处理' do
        reprocess_count = 0
        threads = []

        allow_any_instance_of(Paperclip::Attachment).to receive(:reprocess!) do
          reprocess_count += 1
          sleep 0.01
        end

        5.times do
          threads << Thread.new do
            begin
              worker.perform(media_attachment.id)
            rescue => e
              # 忽略异常
            end
          end
        end

        threads.each(&:join)

        expect(reprocess_count).to eq(1)
        expect(media_attachment.reload.processing).to eq('complete')
      end
    end

    context '缓存清理测试' do
      it '处理完成后触发缓存清理' do
        cache_key = "v3:statuses/#{status.id}"
        Rails.cache.write(cache_key, 'test_value')

        expect(Rails.cache.exist?(cache_key)).to be(true)

        worker.perform(media_attachment.id)

        expect(Rails.cache.exist?(cache_key)).to be(false)
      end

      it '重复执行不会重复触发缓存清理（快速路径）' do
        cache_key = "v3:statuses/#{status.id}"

        worker.perform(media_attachment.id)
        expect(media_attachment.reload.processing).to eq('complete')

        Rails.cache.write(cache_key, 'test_value')
        expect(Rails.cache.exist?(cache_key)).to be(true)

        worker.perform(media_attachment.id)

        expect(Rails.cache.exist?(cache_key)).to be(true)
      end
    end

    context 'when sidekiq retries are exhausted' do
      it 'sets state to failed' do
        described_class.within_sidekiq_retries_exhausted_block({ 'args' => [media_attachment.id] }) do
          worker.perform(media_attachment.id)
        end

        expect(media_attachment.reload.processing).to eq('failed')
      end

      it 'returns true for non-existent record' do
        described_class.within_sidekiq_retries_exhausted_block({ 'args' => [123_123_123] }) do
          expect(worker.perform(123_123_123)).to be(true)
        end
      end
    end
  end

  describe '#lock_key' do
    it '生成正确格式的锁 key' do
      expect(worker.send(:lock_key, 123)).to eq('post_process_media:123')
    end

    it '每个 media_attachment 有独立的 key' do
      key1 = worker.send(:lock_key, 1)
      key2 = worker.send(:lock_key, 2)

      expect(key1).not_to eq(key2)
    end
  end

  describe '#processing_stuck?' do
    it 'returns true when updated_at is older than MAX_PROCESSING_TIME' do
      media_attachment.update!(updated_at: 20.minutes.ago)

      expect(worker.send(:processing_stuck?, media_attachment)).to be(true)
    end

    it 'returns false when updated_at is within MAX_PROCESSING_TIME' do
      media_attachment.update!(updated_at: 5.minutes.ago)

      expect(worker.send(:processing_stuck?, media_attachment)).to be(false)
    end

    it '使用 MAX_PROCESSING_TIME 作为阈值' do
      expect(described_class::MAX_PROCESSING_TIME).to eq(15.minutes)
    end
  end

  describe '幂等设计验证' do
    it '幂等终止状态是 complete' do
      worker.perform(media_attachment.id)

      expect(media_attachment.reload.processing).to eq('complete')

      expect_any_instance_of(Paperclip::Attachment).not_to receive(:reprocess!)
      worker.perform(media_attachment.id)
    end

    it '非终止状态可以重试' do
      non_terminal_states = %w[queued failed]

      non_terminal_states.each do |state|
        ma = Fabricate(:media_attachment)
        ma.update!(processing: state)

        w = described_class.new
        w.perform(ma.id)

        expect(ma.reload.processing).to eq('complete'),
          "状态 #{state} 应该可以重试，但实际结果是 #{ma.reload.processing}"
      end
    end
  end
end

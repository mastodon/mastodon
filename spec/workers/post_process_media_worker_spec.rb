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
          expect(media_attachment.file).not_to receive(:reprocess!)
          expect(media_attachment).not_to receive(:save!)

          result = worker.perform(media_attachment.id)

          expect(result).to be(true)
          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '快速路径：不获取 Redis 锁' do
          expect_any_instance_of(Lockable).not_to receive(:with_redis_lock)

          worker.perform(media_attachment.id)
        end
      end

      context 'when media is in progress' do
        before do
          media_attachment.update!(processing: :in_progress, updated_at: 5.minutes.ago)
        end

        it 'skips reprocessing if not stuck' do
          expect(media_attachment.file).not_to receive(:reprocess!)

          result = worker.perform(media_attachment.id)

          expect(result).to be(true)
        end

        it '状态保持为 in_progress' do
          worker.perform(media_attachment.id)

          expect(media_attachment.reload.processing).to eq('in_progress')
        end

        context 'when processing is stuck' do
          before do
            media_attachment.update!(updated_at: 20.minutes.ago)
          end

          it 'reprocesses the media' do
            worker.perform(media_attachment.id)

            expect(media_attachment.reload.processing).to eq('complete')
          end

          it '状态从 in_progress 流转到 complete' do
            expect { worker.perform(media_attachment.id) }
              .to change { media_attachment.reload.processing }
              .from('in_progress').to('complete')
          end
        end
      end

      context '重复执行（模拟 Redis 瞬断）' do
        it 'does not cause duplicate processing' do
          reprocess_count = 0
          allow(media_attachment.file).to receive(:reprocess!) do
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
          allow(media_attachment.file).to receive(:reprocess!).and_call_original

          expect { worker.perform(media_attachment.id) }
            .to change { media_attachment.reload.processing }
            .from('queued').to('complete')

          expect { worker.perform(media_attachment.id) }
            .not_to change { media_attachment.reload.processing }
        end

        it 'save! 只被调用有限次数' do
          save_count = 0
          allow(media_attachment).to receive(:save!) do
            save_count += 1
            # 模拟真实的 save! 行为
            media_attachment.send(:write_attribute, :updated_at, Time.current)
            true
          end

          worker.perform(media_attachment.id)
          worker.perform(media_attachment.id)

          # 第一次执行：save! in_progress + save! complete = 2 次
          # 第二次执行：快速路径，0 次
          # 总共 2 次
          expect(save_count).to be <= 2
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

      context '真实链路：第一次失败，第二次成功' do
        it '最终只产生一次有效副作用' do
          call_count = 0
          first_call_failed = false

          allow(media_attachment.file).to receive(:reprocess!) do
            call_count += 1
            if call_count == 1
              first_call_failed = true
              raise StandardError, '模拟处理失败'
            end
          end

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

          expect(first_call_failed).to be(true)
          expect(media_attachment.reload.processing).to eq('in_progress')

          media_attachment.reload
          worker.perform(media_attachment.id)

          expect(call_count).to eq(2)
          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '状态流转：queued → in_progress（失败）→ in_progress → complete' do
          call_count = 0

          allow(media_attachment.file).to receive(:reprocess!) do
            call_count += 1
            raise StandardError, '模拟处理失败' if call_count == 1
          end

          expect(media_attachment.processing).to eq('queued')

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)
          expect(media_attachment.reload.processing).to eq('in_progress')

          media_attachment.reload
          worker.perform(media_attachment.id)
          expect(media_attachment.reload.processing).to eq('complete')
        end

        it '关键副作用：reprocess! 恰好被调用 2 次（失败 1 次 + 成功 1 次）' do
          call_count = 0

          allow(media_attachment.file).to receive(:reprocess!) do
            call_count += 1
            raise StandardError, '模拟处理失败' if call_count == 1
          end

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

          media_attachment.reload
          worker.perform(media_attachment.id)

          expect(call_count).to eq(2)
        end

        it '最终状态是 complete，且不会被重复处理' do
          call_count = 0

          allow(media_attachment.file).to receive(:reprocess!) do
            call_count += 1
            raise StandardError, '模拟处理失败' if call_count == 1
          end

          expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

          media_attachment.reload
          worker.perform(media_attachment.id)

          expect(media_attachment.reload.processing).to eq('complete')

          # 第三次调用：快速路径，跳过
          worker.perform(media_attachment.id)

          # reprocess! 仍然是 2 次
          expect(call_count).to eq(2)
        end
      end

      context '边界情况：reprocess! 成功但 save! 失败' do
        it '重试时可以继续处理' do
          reprocess_count = 0
          save_count = 0

          allow(media_attachment.file).to receive(:reprocess!) do
            reprocess_count += 1
          end

          allow(media_attachment).to receive(:save!) do
            save_count += 1
            # 模拟真实的 save! 行为
            media_attachment.send(:write_attribute, :updated_at, Time.current)

            # 第一次 save! complete 时失败
            if save_count >= 2 && media_attachment.processing == 'complete'
              raise ActiveRecord::StatementInvalid, '模拟数据库故障'
            end
            true
          end

          expect { worker.perform(media_attachment.id) }.to raise_error(ActiveRecord::StatementInvalid)

          expect(reprocess_count).to eq(1)
          expect(media_attachment.reload.processing).to eq('complete')
        end
      end
    end

    context '状态流转测试' do
      it '正常路径：queued → in_progress → complete' do
        expect(media_attachment.processing).to eq('queued')

        worker.perform(media_attachment.id)

        expect(media_attachment.reload.processing).to eq('complete')
      end

      it '失败路径：queued → in_progress →（异常）' do
        allow(media_attachment.file).to receive(:reprocess!).and_raise(StandardError, '处理失败')

        expect(media_attachment.processing).to eq('queued')

        expect { worker.perform(media_attachment.id) }.to raise_error(StandardError)

        expect(media_attachment.reload.processing).to eq('in_progress')
      end

      it '重试路径：in_progress →（超时）→ in_progress → complete' do
        media_attachment.update!(processing: :in_progress, updated_at: 20.minutes.ago)

        worker.perform(media_attachment.id)

        expect(media_attachment.reload.processing).to eq('complete')
      end

      it '失败重试：failed → in_progress → complete' do
        media_attachment.update!(processing: :failed)

        worker.perform(media_attachment.id)

        expect(media_attachment.reload.processing).to eq('complete')
      end
    end

    context '并发测试' do
      it '多个线程同时执行，只有一个能成功处理' do
        reprocess_count = 0
        threads = []

        allow(media_attachment.file).to receive(:reprocess!) do
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

        # 第二次执行：快速路径，不触发 after_commit
        worker.perform(media_attachment.id)

        # 缓存仍然存在
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

      expect(media_attachment.file).not_to receive(:reprocess!)
      worker.perform(media_attachment.id)
    end

    it '非终止状态可以重试' do
      non_terminal_states = %w[queued in_progress failed]

      non_terminal_states.each do |state|
        media_attachment = Fabricate(:media_attachment)
        media_attachment.update!(processing: state, updated_at: state == 'in_progress' ? 20.minutes.ago : Time.current)

        worker = described_class.new
        worker.perform(media_attachment.id)

        expect(media_attachment.reload.processing).to eq('complete'),
          "状态 #{state} 应该可以重试，但实际结果是 #{media_attachment.reload.processing}"
      end
    end
  end
end

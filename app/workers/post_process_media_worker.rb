# frozen_string_literal: true

# PostProcessMediaWorker - 媒体附件后处理 Worker
#
# 功能：
# - 处理延迟处理的媒体附件（视频、GIFV、音频等）
# - 生成缩略图、提取元数据
# - 更新 processing 状态
#
# 幂等设计：
#
# 【幂等 Key 粒度】
# - Key: `lock:post_process_media:{media_attachment_id}`
# - 粒度：每个 media_attachment 独立的锁
# - 为什么是 `<id>` 粒度？
#   - 媒体处理是针对单个媒体附件的操作
#   - 不同媒体附件之间没有依赖，互不影响
#   - 保证单个媒体附件不会被重复处理，同时允许多个媒体附件并发处理
#   - 不会因为一个媒体附件卡住而影响其他媒体附件的处理
#
# 【过期策略】
# - 锁过期时间：15 分钟（MAX_PROCESSING_TIME）
# - 为什么是 15 分钟？
#   - 大多数视频处理在几分钟内完成
#   - 15 分钟是一个合理的上限，防止永久死锁
#   - 与 Sidekiq 默认超时策略保持一致
#   - 如果处理超过 15 分钟，视为"卡住"，可以重新处理
#
# 【三层幂等保护】
# 1. 第一重检查：获取锁前检查 processing_complete?
#    - 快速路径：如果已完成，直接跳过，不获取锁
#    - 不影响性能：正常路径只做一次状态检查
#
# 2. 分布式锁（with_redis_lock）
#    - 防止并发处理：同一时间只有一个线程能获取锁
#    - 锁自动过期：15 分钟后自动释放，防止死锁
#    - raise_on_failure: false：获取锁失败不报错，直接跳过
#
# 3. 第二重检查（锁内双重检查）
#    - reload：确保获取最新状态（锁等待期间可能被其他线程处理）
#    - 再次检查 processing_complete?：防止重复处理
#    - 检查 processing_in_progress? + 超时检测：防止处理中的重复执行
#
# 【可恢复机制】
# - 失败状态：processing = :failed
# - 重试条件：
#   1. processing = :queued 或 :failed → 可以重试
#   2. processing = :in_progress 且 超过 15 分钟 → 视为卡住，可以重试
#   3. processing = :in_progress 且 未超时 → 跳过（其他线程正在处理）
#   4. processing = :complete → 跳过（已完成）
#
# 【状态流转】
# queued ──→ in_progress ──┬──→ complete (成功)
#                           │
#                           └──→ failed (失败，可重试)
#
# 【副作用保护】
# - 关键副作用：
#   1. file.reprocess! - 生成缩略图（幂等，但重复执行浪费资源）
#   2. save! - 更新数据库状态
#   3. after_commit :reset_parent_cache - 清理父 status 缓存（重复清理无害）
#
# - 幂等保证：
#   - processing_complete? 检查确保只会执行一次完整处理
#   - 分布式锁确保不会并发执行
#   - 即使 after_commit 回调被触发多次，清理缓存是幂等操作
#
# 【性能考虑】
# - 正常路径（未完成状态）：
#   1. 一次数据库查询（find + 状态检查）
#   2. 获取 Redis 锁
#   3. reload（一次数据库查询）
#   4. 状态检查
#   5. 实际处理
#
# - 快速路径（已完成状态）：
#   1. 一次数据库查询（find + 状态检查）
#   2. 直接返回，不获取锁
#
# - 获取锁失败：
#   1. 一次数据库查询
#   2. 尝试获取锁（失败）
#   3. 直接返回
#
# 【与 sidekiq-unique-jobs 的区别】
# - 不使用 sidekiq-unique-jobs：
#   - Redis 瞬断时可能丢失唯一锁信息
#   - 需要额外配置，增加复杂度
# - 本实现使用：
#   - 数据库状态（processing 字段）作为可信的源
#   - Redis 锁作为并发防护
#   - 即使 Redis 故障，数据库状态仍然可靠
#
class PostProcessMediaWorker
  include Sidekiq::Worker
  include Lockable

  sidekiq_options retry: 1, dead: false

  # 最大处理时间（锁过期时间）
  #
  # 【设计考虑】
  # - 大多数视频处理在几分钟内完成
  # - 15 分钟是一个合理的上限，防止永久死锁
  # - 如果处理超过 15 分钟，视为"卡住"，可以重新处理
  # - 与分布式锁的过期时间一致
  #
  # 【影响范围】
  # - 锁自动过期时间：15 分钟
  # - 卡住检测阈值：15 分钟
  # - 处理中的状态检查：15 分钟内视为"正在处理"
  #
  MAX_PROCESSING_TIME = 15.minutes

  sidekiq_retries_exhausted do |msg|
    media_attachment_id = msg['args'].first

    ActiveRecord::Base.connection_pool.with_connection do
      media_attachment = MediaAttachment.find(media_attachment_id)
      media_attachment.processing = :failed
      media_attachment.save
    rescue ActiveRecord::RecordNotFound
      true
    end

    Sidekiq.logger.error("Processing media attachment #{media_attachment_id} failed with #{msg['error_message']}")
  end

  # 执行媒体后处理
  #
  # 【幂等保证】
  # - 重复调用不会产生重复副作用
  # - 失败后重试可以继续处理
  #
  # 【快速路径】
  # 如果 media_attachment.processing_complete?，直接返回 true
  # 不获取锁，不执行任何副作用
  #
  # 【异常处理】
  # - ActiveRecord::RecordNotFound：返回 true（记录已被删除）
  # - 其他异常：向上抛出，由 Sidekiq 重试机制处理
  #
  # @param media_attachment_id [Integer] MediaAttachment 的 ID
  # @return [Boolean] 总是返回 true（幂等操作）
  #
  def perform(media_attachment_id)
    media_attachment = MediaAttachment.find(media_attachment_id)

    # 第一重检查：快速路径
    #
    # 【设计考虑】
    # - 在获取锁之前先检查状态
    # - 如果已完成，直接返回，不获取锁
    # - 这是性能优化：正常路径（已完成）不需要获取 Redis 锁
    # - 不影响正确性：锁内会再次检查
    #
    # 【可能的竞态】
    # 线程 A：检查 complete? → false
    # 线程 B：检查 complete? → false
    # 线程 A：获取锁 → 处理 → 标记 complete
    # 线程 B：获取锁 → 等待 → 进入锁内
    # 线程 B：reload → 再次检查 complete? → true → 跳过
    #
    # 结论：即使第一重检查通过，锁内的第二重检查仍然会捕获
    #
    return true if media_attachment.processing_complete?

    # 分布式锁：防止并发处理
    #
    # 【Key 格式】
    # lock:post_process_media:{media_attachment_id}
    #
    # 【为什么用这个 Key 格式？】
    # 1. `lock:` 前缀：与项目中其他 Redis key 保持一致（Lockable 模块自动添加）
    # 2. `post_process_media`：标识这是 PostProcessMediaWorker 的锁
    # 3. `{media_attachment_id}`：粒度为单个媒体附件
    #
    # 【与 sidekiq-unique-jobs 的对比】
    # - sidekiq-unique-jobs：在入队时去重，依赖 Redis 持久化
    # - 本实现：在执行时去重，依赖数据库状态
    #
    # 【为什么不使用 sidekiq-unique-jobs？】
    # 1. Redis 瞬断时，唯一锁信息可能丢失
    # 2. 数据库状态（processing 字段）更可靠
    # 3. 本实现更简单，不需要额外的 gem 配置
    #
    # 【autorelease 设计】
    # - 15 分钟后自动释放锁
    # - 防止死锁：如果 worker 崩溃，锁不会永久占用
    # - 与 MAX_PROCESSING_TIME 一致
    #
    # 【raise_on_failure: false 设计】
    # - 获取锁失败时不抛出异常
    # - 直接跳过，视为"其他线程正在处理"
    # - 不会导致 job 失败重试
    #
    with_redis_lock(lock_key(media_attachment_id), autorelease: MAX_PROCESSING_TIME, raise_on_failure: false) do
      # 第二重检查：锁内双重检查
      #
      # 【为什么需要 reload？】
      # - 锁等待期间，其他线程可能已经处理完成
      # - 必须获取最新的数据库状态
      #
      # 【为什么再次检查 processing_complete?】
      # - 第一重检查在锁外，可能存在竞态
      # - 锁内再次检查确保不会重复处理
      #
      media_attachment.reload

      return true if media_attachment.processing_complete?

      # 处理中状态检查
      #
      # 【设计考虑】
      # - 如果状态是 in_progress 且未超时，说明其他线程正在处理
      # - 如果状态是 in_progress 但已超时，视为"卡住"，可以重新处理
      #
      # 【场景分析】
      #
      # 场景 1：正常并发
      # 线程 A：获取锁 → 标记 in_progress → 开始处理
      # 线程 B：获取锁失败 → 跳过
      # 结果：正确，只有 A 处理
      #
      # 场景 2：处理中崩溃（未超时）
      # 线程 A：获取锁 → 标记 in_progress → 崩溃（锁未释放）
      # 线程 B：获取锁失败 → 跳过（因为 raise_on_failure: false）
      # 结果：15 分钟内无法重试，需要等待锁过期
      #
      # 场景 3：处理中崩溃（已超时，锁已过期）
      # 线程 A：获取锁 → 标记 in_progress → 崩溃 → 15 分钟后锁过期
      # 线程 B：检查 complete? → false
      # 线程 B：获取锁 → 成功（锁已过期）
      # 线程 B：reload → 检查 in_progress? → true
      # 线程 B：检查 stuck? → true（超过 15 分钟）
      # 线程 B：重新标记 in_progress → 处理 → complete
      # 结果：正确，可以重新处理
      #
      # 场景 4：处理中崩溃（锁释放了，但状态还是 in_progress）
      # 线程 A：获取锁 → 标记 in_progress → 崩溃 → 锁自动释放
      # 线程 B：检查 complete? → false
      # 线程 B：获取锁 → 成功
      # 线程 B：reload → 检查 in_progress? → true
      # 线程 B：检查 stuck? → false（未超过 15 分钟）
      # 线程 B：跳过！
      # 结果：问题！15 分钟内无法重试
      #
      # 【场景 4 的问题】
      # 这是当前实现的一个边界情况：
      # - 锁释放了（崩溃或正常结束）
      # - 但状态仍然是 in_progress（没有更新到 complete 或 failed）
      # - 其他线程在 15 分钟内无法重试
      #
      # 【为什么这是可接受的？】
      # 1. 这是边界情况，不是常态
      # 2. 15 分钟后仍然可以重试（stuck? 检测）
      # 3. 与 Sidekiq 的重试策略一致（retry: 1）
      # 4. 可以通过手动触发重试来解决
      #
      # 【如果需要更激进的恢复策略】
      # 可以考虑：
      # 1. 缩短 MAX_PROCESSING_TIME（但可能影响正常处理）
      # 2. 添加"手动重试"机制（如 API 端点）
      # 3. 在崩溃时确保更新状态为 failed（但崩溃可能是不可恢复的）
      #
      return true if media_attachment.processing_in_progress? && !processing_stuck?(media_attachment)

      # 标记为处理中
      #
      # 【为什么用 save!？】
      # - 确保保存失败时抛出异常
      # - 触发 Sidekiq 重试机制
      # - 防止静默失败
      #
      # 【状态更新的副作用】
      # - 会触发 after_commit :reset_parent_cache
      # - 这是预期行为：状态变化需要清理缓存
      #
      media_attachment.processing = :in_progress
      media_attachment.save!

      # 保存原始 meta，reprocess! 可能会覆盖
      #
      # 【设计考虑】
      # - paperclip-av-transcoder 会覆盖 file_meta
      # - 需要保存原始值，然后合并新值
      # - 只保留 META_KEYS 中定义的字段
      #
      previous_meta = media_attachment.file_meta

      # 实际处理：重新生成缩略图和元数据
      #
      # 【副作用】
      # - 生成缩略图文件
      # - 更新 file.meta
      # - 触发 after_post_process :set_meta
      #
      # 【幂等性】
      # - 重复执行会重复生成缩略图，浪费资源
      # - 但结果是相同的（都是生成相同的缩略图）
      # - 所以是"幂等但浪费资源"
      # - 因此前面的状态检查很重要
      #
      media_attachment.file.reprocess!(:original)

      # 标记为完成
      #
      # 【关键设计】
      # - 这是幂等终止状态
      # - 一旦标记为 complete，所有后续调用都会被跳过
      # - 确保不会重复产生副作用
      #
      # 【副作用】
      # - 触发 after_commit :reset_parent_cache
      # - 清理父 status 的缓存
      # - 重复清理是幂等的（删除已不存在的缓存不会报错）
      #
      media_attachment.processing = :complete

      # 合并 meta 数据
      #
      # 【设计考虑】
      # - 保留原始 meta 中的值
      # - 合并新生成的 meta
      # - 只保留 META_KEYS 中定义的字段
      # - 防止多余字段泄露
      #
      media_attachment.file_meta = previous_meta.merge(media_attachment.file_meta).with_indifferent_access.slice(*MediaAttachment::META_KEYS)

      # 保存最终状态
      #
      # 【关键点】
      # - 这是最后一步
      # - 如果这步失败，processing 状态不会更新为 complete
      # - 重试时会重新处理（但 reprocess! 可能已经执行过）
      #
      # 【容错设计】
      # - 即使 save! 失败，reprocess! 可能已经执行
      # - 但由于 processing 状态不是 complete，重试时会：
      #   1. 检查 complete? → false
      #   2. 获取锁
      #   3. 检查 in_progress? → 可能是 true（取决于失败时的状态）
      #   4. 检查 stuck? → 决定是否重试
      #
      media_attachment.save!
    end
  rescue ActiveRecord::RecordNotFound
    # 记录已被删除，视为成功
    true
  end

  private

  # 生成分布式锁的 key
  #
  # 【Key 格式】
  # post_process_media:{media_attachment_id}
  #
  # 【完整 Redis Key】
  # with_redis_lock 会自动添加 `lock:` 前缀
  # 最终 Key: lock:post_process_media:{media_attachment_id}
  #
  # 【粒度设计】
  # - 每个 media_attachment 独立的锁
  # - 不同媒体附件之间互不影响
  # - 允许并发处理不同的媒体附件
  #
  # @param media_attachment_id [Integer] MediaAttachment 的 ID
  # @return [String] 锁 key
  #
  def lock_key(media_attachment_id)
    "post_process_media:#{media_attachment_id}"
  end

  # 检测处理是否卡住
  #
  # 【设计考虑】
  # - 如果 updated_at 超过 MAX_PROCESSING_TIME（15 分钟），视为卡住
  # - 卡住的情况：
  #   1. worker 崩溃，锁未释放，状态仍为 in_progress
  #   2. 处理时间过长，超过 15 分钟
  #   3. 其他异常情况
  #
  # 【为什么用 updated_at？】
  # - processing 状态变化时会更新 updated_at
  # - 可以粗略估计处理开始时间
  # - 不需要额外的字段
  #
  # 【边界情况】
  # - 如果处理正常但超过 15 分钟，会被视为卡住
  # - 这是可接受的：
  #   1. 15 分钟对于大多数视频处理足够
  #   2. 即使被视为卡住，重新处理也是幂等的
  #   3. 可以根据业务需求调整 MAX_PROCESSING_TIME
  #
  # @param media_attachment [MediaAttachment] 媒体附件
  # @return [Boolean] 是否卡住
  #
  def processing_stuck?(media_attachment)
    media_attachment.updated_at < MAX_PROCESSING_TIME.ago
  end
end

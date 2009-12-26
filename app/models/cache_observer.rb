class CacheObserver < ActiveRecord::Observer
  observe Answer, Category, Question, User

  def before_update(record)
    Rails.logger.debug "----observe #{record.class} is updated"
    #@record_change = (!record.new_record? && record.changed?)
  end

  def after_update(record)
    record.class.expire_cache("#{record.class}.cache_find(#{record.id})")
    Rails.logger.debug "----end observe #{record.class}"
  end

protected
  def record_change?
    @record_change
  end
end

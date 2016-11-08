class Api::V1::TimelinesController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!, only: [:home, :mentions]

  respond_to :json

  def home
    @statuses = Feed.new(:home, current_account).get(20, params[:max_id], params[:since_id]).to_a
    set_maps(@statuses)
    render action: :index
  end

  def mentions
    @statuses = Feed.new(:mentions, current_account).get(20, params[:max_id], params[:since_id]).to_a
    set_maps(@statuses)
    render action: :index
  end

  def public
    @statuses = Status.as_public_timeline(current_account).paginate_by_max_id(20, params[:max_id], params[:since_id]).to_a
    set_maps(@statuses)
    render action: :index
  end

  def tag
    @tag = Tag.find_by(name: params[:id].downcase)

    if @tag.nil?
      @statuses = []
    else
      @statuses = Status.as_tag_timeline(@tag, current_account).paginate_by_max_id(20, params[:max_id], params[:since_id]).to_a
      set_maps(@statuses)
    end

    render action: :index
  end
end

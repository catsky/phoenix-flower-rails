class ApiController < ApplicationController

  before_filter :prepare_api_before_filter
  before_filter :prepare_api_after_action

  def ping
    render json: {
      api_version: controller_name, 
      now: @started_at, 
      now_epoch: @started_at.to_i
    }, status: 200
  end


  def start_benchmark
    @started_at = Time.zone.now
  end

  def end_benchmark
    @ended_at = Time.now
  end

  def prepare_api_before_filter
    start_benchmark
    set_trust_headers
  end
  
  def prepare_api_after_action
    end_benchmark
  end

    def set_trust_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Request-Method'] = '*'
  end

end

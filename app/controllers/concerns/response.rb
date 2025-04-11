module Response
    def render_success(data, status = :ok)
      render json: {
        status: 'success',
        data: data
      }, status: status
    end
  
    def render_error(message, status = :bad_request)
      render json: {
        status: 'error',
        message: message
      }, status: status
    end
  end
  
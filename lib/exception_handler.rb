module ExceptionHandler
  module_function

  def capture_exception(message, extra_context = {})
    Raven.capture_exception(message)
    Raven.extra_context(extra_context)
  end
end
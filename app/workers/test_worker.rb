class TestWorker
  include Sidekiq::Worker

  def perform(args)
    puts args.keys
  end
end

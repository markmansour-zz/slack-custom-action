class SlackNotifierCustomAction
  def initialize
    cp = Aws::CodePipeline::Client.new(region: 'us-east-1')

    poll_results = cp.poll_for_jobs({
        action_type_id: {
          category: 'Deploy',
          owner: 'Custom',
          provider: 'Slack-Notifier',
          version: '2'
        },
        max_batch_size: 1
      })

    job = poll_results.jobs.first

    return puts "No new job found" if ! job

    puts "Job ID: #{job.id}"

    cp.acknowledge_job(job_id: job.id, nonce: job.nonce)

    # perform our important logic
    execution_id = send_motivational_message_to_slack

    cp.put_job_success_result({
        job_id: job.id,
        execution_details: {
          summary: 'Success',
          external_execution_id: execution_id,
          percent_complete: 100
        }
      })
  end

  def send_motivational_message_to_slack
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end

    client = Slack::Web::Client.new

    client.auth_test

    general_channel = client.channels_list['channels'].detect { |c| c['name'] == 'general' }

    result = client.chat_postMessage(
      channel: general_channel['id'], 
      text: dog_says, 
      icon_emoji: ":dog:", 
      username: "dogbot")

    "p" + result["ts"].tr('.', "")
  end

  def dog_says
    [
      'Be the person your dog thinks you are',
      "It's not the size of the dog in the fight, it's the size of the fight in the dog",
      "People often say that motivation doesn't last.  Well, neither does bathing - that's why we recommend it daily",
      "Outside of a dog, a book is man's best friend. Inside of a dog it's too dark to read.",
      "If you pick up a starving dog and make him prosperous he will not bite you. This is the principal difference between a dog and man.",
      'woof',
      "The better I get to know men, the more I find myself loving dogs.",
    ].sample
  end
end

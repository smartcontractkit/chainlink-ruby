module SpecHelpers

  def run_delayed_jobs
    Delayed::Job.pluck(:id).each do |dj_id|
      dj = Delayed::Job.find(dj_id)
      dj.invoke_job
      dj.destroy
    end
  end

  def run_generated_jobs
    old_ids = Delayed::Job.pluck(:id)

    yield

    new_ids = Delayed::Job.pluck(:id) - old_ids
    new_ids.each do |dj_id|
      dj = Delayed::Job.find(dj_id)
      dj.invoke_job
      dj.destroy
    end
  end

  def run_scheduled_assignments
    run_generated_jobs do
      AssignmentScheduler.perform
    end
  end

  def run_ethereum_contract_confirmer
    run_generated_jobs do
      EthereumContractConfirmer.perform
    end
  end

  def run_ethereum_confirmation_watcher
    run_generated_jobs do
      EthereumConfirmationWatcher.perform
    end
  end

  def run_term_janitor_clean_up
    run_generated_jobs do
      TermJanitor.clean_up
    end
  end

  def ethereum_balance_watcher
    run_generated_jobs do
      EthereumBalanceWatcher.perform
    end
  end

end

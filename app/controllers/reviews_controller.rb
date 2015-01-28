class ReviewsController < ApplicationController
  before_filter :authenticate_user!

  def create
    remove_converted!
    note = NoteSync.new(project, pull_request).call(require_merge: false)

    if note
      project.reviewers.each do |reviewer|
        NotesMailer.reviewer(project, note, to: reviewer.email).deliver_now
      end
      render text: "Awesome, emails have been sent. Excuse the ugly."
    else
      render text: "No email sent. Something wrong?"
    end

  end

  private

  def remove_converted!
    converted = project.converted_pull_requests.find_by(pull_request_id: pull_request.id)
    return unless converted

    converted.note.destroy
    converted.destroy
  end

  def project
    @project ||= current_team.projects.find(params[:project_id])
  end

  def repository
    @repository ||= project.repositories.find(params[:repository_id])
  end

  def client
    @client ||= GithubClient.new(project)
  end

  def pull_request
    @pull_request ||= begin
      pull = client.pull_request(repository.full_name, params[:pull_request_id])
      Git::PullRequest.from_api_response(pull, repository: repository, client: client)
    end
  end
end

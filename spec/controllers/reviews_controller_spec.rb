require 'rails_helper'

RSpec.describe ReviewsController, :type => :controller do
  let(:user) { FactoryGirl.create(:github_user) }
  let!(:project) { FactoryGirl.create(:project, user: user, team: user.team) }
  let!(:repository) { FactoryGirl.create(:customer_know, project: project) }

  before(:each) {
    sign_in(user)
    request.env["HTTP_ACCEPT"] = 'application/json'
  }

  describe "POST create" do
    it "redirects not logged in" do
      sign_out(user)
      post :create
      expect(response).not_to be_success
    end

    it "creates a note", vcr: { cassette_name: "reviews-controller_create-note"  } do
      expect {
        post :create, pull_request_id: 6, repository_id: repository.id, project_id: project.id
      }.to change{ project.notes.count }.by(1)
    end

    context "with reviewers" do
      let!(:r1) { FactoryGirl.create(:reviewer) }
      let!(:r2) { FactoryGirl.create(:reviewer) }

      before(:each) {
        project.reviewers << r1
        project.reviewers << r2
      }

      it "sends out emails", vcr: { cassette_name: "reviews-controller_create-note" } do
        expect {
          post :create, pull_request_id: 6, repository_id: repository.id, project_id: project.id
        }.to change{ ActionMailer::Base.deliveries.count }.by(2)
      end

      context "with a converted pull request" do
        let!(:note) { FactoryGirl.create(:note, project: project) }
        let!(:converted) { project.converted_pull_requests.create!(note: note, pull_request_id: 28002510) }

        it "removes the old note", vcr: { cassette_name: "reviews-controller_with-old-note"  } do
          expect {
            post :create, pull_request_id: 6, repository_id: repository.id, project_id: project.id
          }.to change{ Note.find_by(id: note.id) }.from(note).to(nil)
        end

        it "creates a note", vcr: { cassette_name: "reviews-controller_with-old-note"  } do
          expect {
            expect {
              post :create, pull_request_id: 6, repository_id: repository.id, project_id: project.id
            }.not_to change{ project.notes.count }
          }.to change{ project.notes.last }
        end
      end
    end
  end
end

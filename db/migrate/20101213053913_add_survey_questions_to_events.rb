class AddSurveyQuestionsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :survey_question, :string
    add_column :attendees, :survey_question_value, :string
  end

  def self.down
    remove_column :attendees, :survey_question_value
    remove_column :events, :survey_question
  end
end
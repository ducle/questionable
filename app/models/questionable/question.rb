module Questionable
  class Question < ActiveRecord::Base
    attr_accessible :title, :input_type, :note, :category
    has_many :options, :order => 'questionable_options.position ASC', :dependent => :destroy
    has_many :assignments, :dependent => :destroy
    has_many :subjects, :through => :assignments
    has_many :answers, :through => :assignments

    validates_presence_of :title

    def accepts_multiple_answers?
      ['checkboxes', 'multiselect'].include?(self.input_type)
    end

    def answers_for_user(user)
      answers = self.answers.where(user_id: user.id)
      answers.any? ? answers : [self.answers.build(user_id: user.id)]
    end

    def self.with_subject(subject)
      if subject.kind_of?(Symbol) or subject.kind_of?(String)
        Questionable::Question.joins('INNER JOIN questionable_assignments ON questionable_assignments.question_id = questionable_questions.id').where(:questionable_assignments => { :subject_type => subject }).order('questionable_assignments.position')
      else
        Questionable::Question.joins('INNER JOIN questionable_assignments ON questionable_assignments.question_id = questionable_questions.id').where(:questionable_assignments => { :subject_type => subject.class.to_s, :subject_id => subject.id }).order('questionable_assignments.position')
      end
    end
  end
end


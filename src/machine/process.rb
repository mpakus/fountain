# frozen_string_literal: true

require 'comandor'
require 'awesome_print'

module Machine
  class Process
    extend Comandor

    AVAILABLE_STAGES = %i[ManualReview PhoneInterview BackgroundCheck DocumentSigning].freeze

    def perform(commands)
      @users = {}
      @stages = []
      process(commands)
    end

    private

    def process(commands)
      commands.collect { |command| send("command_#{command[0].to_s.downcase}".to_sym, command[1..-1]) }.reject(&:nil?)
    end

    # --- commands_*

    # DEFINE [STAGE1 ...  STAGE*]
    def command_define(stages)
      @stages = stages.collect do |stage|
        stage = stage.to_sym
        unless AVAILABLE_STAGES.include? stage
          return error(:define, "Wrong Stage value '#{stage}', available values #{AVAILABLE_STAGES.join(', ')}")
        end
        stage
      end
      "DEFINE #{stages.join(' ')}"
    end

    # CREATE [EMAIL]
    def command_create(params)
      return 'Duplicate applicant' unless @users[params[0]].nil?
      # here we can use params[1] as Default Stage but need to validate it
      @users[params[0]] = { stage: @stages.first, hired: false, rejected: false }
      "CREATE #{params[0]}"
    end

    # ADVANCE [EMAIL] [STAGE]
    def command_advance(params)
      email, stage = params
      msg = "Already in #{@stages.last}"
      user = @users[email]
      return "Wrong User E-mail #{email}" if user.nil?
      return msg if user[:stage] == @stages.last # if user in the last stage already
      if stage.nil?
        i = @stages.index(user[:stage]) # check limits
        if i.nil?
          stage = @stages.first
        else
          return msg if i > @stages.count - 1
          stage = @stages[i + 1]
        end
      end
      stage = stage.to_sym
      return msg if user[:stage] == stage
      user[:stage] = stage
      # if stage == @stages.last # if stage is last, so we hire him and remove stage
      #   user[:hired] = true
      #   user[:stage] = nil
      # end
      @users[email] = user
      "ADVANCE #{email}"
    end

    # DECIDE [EMAIL] [STAGE]
    def command_decide(params)
      email = params[0]
      msg = "Failed to decide for #{email}"
      return msg if @users[email].nil?
      decision = (params[1] == '1')
      return msg if decision && @users[email][:stage] != @stages.last
      @users[email][:stage] = nil
      if decision
        @users[email][:hired] = true
        "Hired #{email}"
      else
        @users[email][:rejected] = true
        "Rejected #{email}"
      end
    end

    # STATS
    def command_stats(_params)
      # ManualReview 0 BackgroundCheck 0 DocumentSigning 0 Hired 0 Rejected 0
      reset_state!
      @users.each_key do |k|
        user = @users[k]
        @state[user[:stage]] += 1 if user[:stage]
        @state[:hired] += 1 if user[:hired]
        @state[:rejected] += 1 if user[:rejected]
      end
      @stages.collect { |k| "#{k} #{@state[k]}" }.join(' ') + " Hired #{@state[:hired]} Rejected #{@state[:rejected]}"
    end

    # --- helpers

    def reset_state!
      @state = { hired: 0, rejected: 0 }
      @stages.collect { |stage| @state[stage] = 0 }
    end
  end
end

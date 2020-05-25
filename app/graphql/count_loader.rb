# frozen_string_literal: true

class CountLoader < GraphQL::Batch::Loader
  def initialize(model:, association_name:, column: model.primary_key)
    @model = model
    @association_name = association_name
    @column = column
    validate
  end

  def perform(keys)
    fk = @model.reflect_on_association(@association_name).foreign_key
    counts = @model.joins(@association_name).where(@column => keys).group(fk).count
    keys.each do |key|
      fulfill(key, counts.fetch(key, 0))
    end
  end

  protected

  def validate
    unless @model.reflect_on_association(@association_name)
      raise ArgumentError, "No association #{@association_name} on #{@model}"
    end
  end
end
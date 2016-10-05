class AddDashboardToQueryConstraints < ActiveRecord::Migration
  def up
    execute "ALTER TABLE queries DROP CONSTRAINT validate_field"
    execute "ALTER TABLE queries DROP CONSTRAINT validate_method"

    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_field
      CHECK ((
        provider = 'slack'
        AND (
          field = 'nickname'
          OR field = 'email'
          OR field = 'full_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field LIKE 'dashboard:%'
        )
      ) OR
      (
        provider = 'facebook'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'gender'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field LIKE 'dashboard:%'
        )
      ) OR
      (
        provider = 'kik'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field LIKE 'dashboard:%'
        )
      )
    )"
    )
    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_method
      CHECK (
        (
          provider = 'slack'
          AND (
            field = 'nickname'
            OR field = 'email'
            OR field = 'full_name'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (provider = 'facebook' OR provider = 'kik')
          AND (
            field = 'first_name'
            OR field = 'last_name'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          provider = 'facebook'
          AND (
            field = 'gender'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik'
          )
          AND (
            field = 'interaction_count'
          )
          AND (
            method = 'equals_to'
            OR method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik'
          )
          AND (
            field = 'interacted_at'
            OR field = 'user_created_at'
            OR field LIKE 'dashboard:%'
          )
          AND (
            method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
      )"
    )
  end

  def down
    execute "ALTER TABLE queries DROP CONSTRAINT validate_field"
    execute "ALTER TABLE queries DROP CONSTRAINT validate_method"

    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_field
      CHECK ((
        provider = 'slack'
        AND (
          field = 'nickname'
          OR field = 'email'
          OR field = 'full_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
        )
      ) OR
      (
        provider = 'facebook'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'gender'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
        )
      ) OR
      (
        provider = 'kik'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
        )
      )
    )"
    )
    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_method
      CHECK (
        (
          provider = 'slack'
          AND (
            field = 'nickname'
            OR field = 'email'
            OR field = 'full_name'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (provider = 'facebook' OR provider = 'kik')
          AND (
            field = 'first_name'
            OR field = 'last_name'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          provider = 'facebook'
          AND (
            field = 'gender'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik'
          )
          AND (
            field = 'interaction_count'
          )
          AND (
            method = 'equals_to'
            OR method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik'
          )
          AND (
            field = 'interacted_at'
            OR field = 'user_created_at'
          )
          AND (
            method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
      )"
    )

  end
end

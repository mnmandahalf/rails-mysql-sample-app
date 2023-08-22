# frozen_string_literal: true

module CustomExecuteOverride
  def execute(sql, name = nil, async: false)
    # ALGORITHM=INSTANT is not supported with LOCK=NONE
    # sql = add_algorithm_instant(sql)
    sql = add_lock_none(sql)
    super(sql, name, async: async)
  end

  private

  def add_algorithm_instant(sql)
    if supported_sql_for_check_online_ddl?(sql)
      sql = sql.gsub(/,\s*ALGORITHM\s*=\s*\w+\s*/i, "").squeeze(" ").strip
      sql = "#{sql.chomp(';')}, ALGORITHM=INSTANT;"
    end
    sql
  end

  def add_lock_none(sql)
    if supported_sql_for_check_online_ddl?(sql)
      sql = sql.gsub(/,\s*LOCK\s*=\s*\w+\s*/i, "").squeeze(" ").strip
      sql = "#{sql.chomp(';')}, LOCK=NONE;"
    end
    sql
  end

  def supported_sql_for_check_online_ddl?(sql)
    sql.upcase.include?("ALTER TABLE") ||
      sql.upcase.include?("CREATE INDEX") ||
      sql.upcase.include?("CREATE UNIQUE INDEX") ||
      sql.upcase.include?("CREATE FULLTEXT INDEX") ||
      sql.upcase.include?("CREATE SPATIAL INDEX") ||
      sql.upcase.include?("ALTER INDEX") ||
      sql.upcase.include?("DROP INDEX")
  end
end

namespace :db do
  task prepend_custom_execute: :environment do
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.prepend(CustomExecuteOverride)
  end

  Rake::Task["db:migrate"].enhance(["db:prepend_custom_execute"])
  Rake::Task["db:rollback"].enhance(["db:prepend_custom_execute"])
end

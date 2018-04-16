require_relative "test_helper"

class BestIndexTest < Minitest::Test
  def test_where
    assert_best_index ({table: "users", columns: ["city_id"]}), "SELECT * FROM users WHERE city_id = 1"
  end

  def test_all_values
    index = PgHero.best_index("SELECT * FROM users WHERE login_attempts = 1 ORDER BY created_at")
    expected = {
      found: true,
      structure: {table: "users", where: [{column: "login_attempts", op: "="}], sort: [{column: "created_at", direction: "asc"}]},
      index: {table: "users", columns: ["login_attempts", "created_at"]},
      rows: 10000,
      row_estimates: {"login_attempts (=)" => 333, "created_at (sort)" => 1},
      row_progression: [10000, 333, 0]
    }
    assert_equal expected, index
  end

  def test_where_multiple_columns
    assert_best_index ({table: "users", columns: ["city_id", "login_attempts"]}), "SELECT * FROM users WHERE city_id = 1 and login_attempts = 2"
  end

  def test_where_unique
    assert_best_index ({table: "users", columns: ["email"]}), "SELECT * FROM users WHERE city_id = 1 AND email = 'person2@example.org'"
  end

  def test_order
    assert_best_index ({table: "users", columns: ["created_at"]}), "SELECT * FROM users ORDER BY created_at"
  end

  def test_order_multiple
    assert_best_index ({table: "users", columns: ["login_attempts", "created_at"]}), "SELECT * FROM users ORDER BY login_attempts, created_at"
  end

  def test_order_multiple_direction
    assert_best_index ({table: "users", columns: ["login_attempts"]}), "SELECT * FROM users ORDER BY login_attempts DESC, created_at"
  end

  def test_order_multiple_unique
    assert_best_index ({table: "users", columns: ["id"]}), "SELECT * FROM users ORDER BY id, created_at"
  end

  def test_where_unique_order
    assert_best_index ({table: "users", columns: ["email"]}), "SELECT * FROM users WHERE email = 'person2@example.org' ORDER BY created_at"
  end

  def test_where_order
    assert_best_index ({table: "users", columns: ["login_attempts", "created_at"]}), "SELECT * FROM users WHERE login_attempts = 1 ORDER BY created_at"
  end

  def test_where_order_unknown
    assert_best_index ({table: "users", columns: ["login_attempts"]}), "SELECT * FROM users WHERE login_attempts = 1 ORDER BY NOW()"
  end

  def test_where_in
    assert_best_index ({table: "users", columns: ["city_id"]}), "SELECT * FROM users WHERE city_id IN (1, 2)"
  end

  def test_like
    assert_best_index ({table: "users", columns: ["email gist_trgm_ops"], using: "gist"}), "SELECT * FROM users WHERE email LIKE ?"
  end

  def test_like_where
    assert_best_index ({table: "users", columns: ["city_id"]}), "SELECT * FROM users WHERE city_id = ? AND email LIKE ?"
  end

  def test_like_where2
    assert_best_index ({table: "users", columns: ["email gist_trgm_ops"], using: "gist"}), "SELECT * FROM users WHERE email LIKE ? AND active = ?"
  end

  def test_ilike
    assert_best_index ({table: "users", columns: ["email gist_trgm_ops"], using: "gist"}), "SELECT * FROM users WHERE email ILIKE ?"
  end

  def test_not_equals
    assert_best_index ({table: "users", columns: ["login_attempts"]}), "SELECT * FROM users WHERE city_id != ? and login_attempts = 2"
  end

  def test_not_in
    assert_best_index ({table: "users", columns: ["login_attempts"]}), "SELECT * FROM users WHERE city_id NOT IN (?) and login_attempts = 2"
  end

  def test_between
    assert_best_index ({table: "users", columns: ["city_id"]}), "SELECT * FROM users WHERE city_id BETWEEN 1 AND 2"
  end

  def test_multiple_range
    assert_best_index ({table: "users", columns: ["city_id"]}), "SELECT * FROM users WHERE city_id > ? and login_attempts > ?"
  end

  def test_where_prepared
    assert_best_index ({table: "users", columns: ["city_id"]}), "SELECT * FROM users WHERE city_id = $1"
  end

  def test_where_normalized
    assert_best_index ({table: "users", columns: ["city_id"]}), "SELECT * FROM users WHERE city_id = ?"
  end

  def test_is_null
    assert_best_index ({table: "users", columns: ["zip_code"]}), "SELECT * FROM users WHERE zip_code IS NULL"
  end

  def test_is_null_equal
    assert_best_index ({table: "users", columns: ["zip_code", "login_attempts"]}), "SELECT * FROM users WHERE zip_code IS NULL AND login_attempts = ?"
  end

  def test_is_not_null
    assert_best_index ({table: "users", columns: ["login_attempts"]}), "SELECT * FROM users WHERE zip_code IS NOT NULL AND login_attempts = ?"
  end

  def test_update
    assert_best_index ({table: "users", columns: ["city_id"]}), "UPDATE users SET email = 'test' WHERE city_id = 1"
  end

  def test_delete
    assert_best_index ({table: "users", columns: ["city_id"]}), "DELETE FROM users WHERE city_id = 1"
  end

  def test_parse_error
    assert_no_index "Parse error", "SELECT *123'"
  end

  def test_stats_not_found
    assert_no_index "Stats not found", "SELECT * FROM non_existent_table WHERE id = 1"
  end

  def test_unknown_structure
    assert_no_index "Unknown structure", "SELECT NOW()"
  end

  def test_where_or
    assert_no_index "Unknown structure", "SELECT FROM users WHERE login_attempts = 0 OR login_attempts = 1"
  end

  def test_where_nested_or
    assert_no_index "Unknown structure", "SELECT FROM users WHERE city_id = 1 AND (login_attempts = 0 OR login_attempts = 1)"
  end


  def test_multiple_tables
    assert_no_index "JOIN not supported yet", "SELECT * FROM users INNER JOIN cities ON cities.id = users.city_id"
  end

  def test_no_columns
    assert_no_index "No columns to index", "SELECT * FROM users"
  end

  def test_small_table
    assert_no_index "No index needed if less than 500 rows", "SELECT * FROM states WHERE name = 'State 1'"
  end

  def test_system_table
    assert_no_index "System table", "SELECT COUNT(*) AS count FROM pg_extension WHERE extname = ?"
  end

  def test_insert
    assert_no_index "INSERT statement", "INSERT INTO users (login_attempts) VALUES (1)"
  end

  def test_set
    assert_no_index "SET statement", "set client_encoding to 'UTF8'"
  end

  protected

  def assert_best_index(expected, statement)
    index = PgHero.best_index(statement)
    assert_nil index[:explanation]
    assert index[:found]
    assert_equal expected, index[:index]
  end

  def assert_no_index(explanation, statement)
    index = PgHero.best_index(statement)
    assert !index[:found]
    assert_equal explanation, index[:explanation]
  end
end

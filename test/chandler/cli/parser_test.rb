require "minitest_helper"
require "chandler/cli/parser"

class Chandler::CLI::ParserTest < Minitest::Test
  def test_usage
    parser = parse_arguments
    assert_match(/^Usage: chandler/, parser.usage)
    assert_match("chandler scans your git repository", parser.usage)
    assert_match("--git", parser.usage)
    assert_match("--github", parser.usage)
    assert_match("--changelog", parser.usage)
    assert_match("--dry-run", parser.usage)
    assert_match("--debug", parser.usage)
    assert_match("--help", parser.usage)
    assert_match("--version", parser.usage)
  end

  def test_args
    assert_equal([], parse_arguments.args)
    assert_equal([], parse_arguments("--dry-run").args)
    assert_equal(["push"], parse_arguments("push").args)
    assert_equal(["push"], parse_arguments("--debug", "push").args)
    assert_equal(["push"], parse_arguments("push", "--git=.git").args)
    assert_equal(
      ["push", "v1.0.1"],
      parse_arguments("push", "v1.0.1", "--dry-run").args
    )
  end

  def test_config_is_unchanged_when_no_options_are_specified
    default_config = Chandler::Configuration.new
    config = parse_arguments.config

    assert_equal(config.logger.verbose?, default_config.logger.verbose?)
    assert_equal(config.dry_run?, default_config.dry_run?)
    assert_equal(config.git_path, default_config.git_path)
    assert_equal(config.github_repository, default_config.github_repository)
    assert_equal(config.changelog_path, default_config.changelog_path)
  end

  def test_config_is_changed_based_on_options
    args = %w(
      --debug
      push
      --git=../test/.git
      --github=test/repo
      --changelog=../test/changes.md
      --dry-run
    )
    config = parse_arguments(*args).config

    assert(config.logger.verbose?)
    assert(config.dry_run?)
    assert_equal("../test/.git", config.git_path)
    assert_equal("test/repo", config.github_repository)
    assert_equal("../test/changes.md", config.changelog_path)
  end

  private

  def parse_arguments(*args)
    Chandler::CLI::Parser.new(args)
  end
end

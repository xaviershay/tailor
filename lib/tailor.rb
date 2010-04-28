$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'fileutils'
require 'pathname'
require 'tailor/file_line'
require 'tailor/spacing'

module Tailor
  VERSION = '0.0.3'

  RUBY_KEYWORDS_WITH_END = [
    'begin',
    'case',
    'class',
    'def',
    'do',
    'if',
    'unless',
    'until',
    'while'
    ]

  # Check all files in a directory for style problems.
  #
  # @param [String] project_base_dir Path to a directory to recurse into and
  #   look for problems in.
  # @return [Hash] Returns a hash that contains file_name => problem_count.
  def self.check project_base_dir
    # Get the list of files to process
    ruby_files_in_project = project_file_list(project_base_dir)

    files_and_problems = Hash.new

    # Process each file
    ruby_files_in_project.each do |file_name|
      problems = find_problems file_name
      files_and_problems[file_name] = problems
    end

    files_and_problems
  end

  # Gets a list of .rb files in the project.  This gets each file's absolute
  #   path in order to alleviate any possible confusion.
  #
  # @param [String] base_dir Directory to start recursing from to look for .rb
  #   files
  # @return [Array] Sorted list of absolute file paths in the project
  def self.project_file_list base_dir
    if File.directory? base_dir
      FileUtils.cd base_dir
    end

    # Get the .rb files
    ruby_files_in_project = Dir.glob(File.join('*', '**', '*.rb'))
    Dir.glob(File.join('*.rb')).each { |file| ruby_files_in_project << file }

    # Expand paths to all files in the list
    list_with_absolute_paths = Array.new
    ruby_files_in_project.each do |file|
      list_with_absolute_paths << File.expand_path(file)
    end

    list_with_absolute_paths.sort
  end

  # Checks a sing file for all defined styling parameters.
  #
  # @param [String] file_name Path to a file to check styling on.
  # @return [Number] Returns the number of errors on the file.
  def self.find_problems file_name
    source = File.open(file_name, 'r')
    file_path = Pathname.new(file_name)

    puts
    puts "#-------------------------------------------------------------------"
    puts "# Looking for bad style in:"
    puts "# \t'#{file_path}'"
    puts "#-------------------------------------------------------------------"

    @problem_count = 0
    line_number = 1
    source.each_line do |source_line|
      line = FileLine.new(source_line, file_path, line_number)

      # Check for indenting by spaces only
      @problem_count += 1 if line.hard_tabbed?

      # Check for camel-cased methods
      @problem_count += 1 if line.method_line? and line.camel_case_method?

      # Check for non-camel-cased classes
      @problem_count += 1 if line.class_line? and line.snake_case_class?

      # Check for trailing whitespace
      @problem_count += 1 if line.trailing_whitespace?

      # Check for long lines
      @problem_count += 1 if line.too_long?

      # Check for spacing after commas
      @problem_count += 1 if line.more_than_one_space_after_comma?

      # Check for spacing after commas
      @problem_count += 1 if line.no_space_after_comma?

      # Check for spacing after commas
      @problem_count += 1 if line.space_before_comma?

      # Check for spacing after open parentheses
      @problem_count += 1 if line.space_after_open_parenthesis?

      # Check for spacing after open brackets
      @problem_count += 1 if line.space_after_open_bracket?

      # Check for spacing after closed parentheses
      @problem_count += 1 if line.space_before_closed_parenthesis?

      # Check for spacing after closed brackets
      @problem_count += 1 if line.space_before_closed_bracket?

      line_number += 1
    end

    @problem_count
  end

  # Prints a summary report that shows which files had how many problems.
  #
  # @param [Hash] files_and_problems Returns a hash that contains
  #   file_name => problem_count.
  def self.print_report files_and_problems
    puts
    puts "The following files are out of style:"

    files_and_problems.each_pair do |file, problem_count|
      file_path = Pathname.new(file)
      unless problem_count == 0
        print "\t#{problem_count} problems in: "
        puts "#{file_path.relative_path_from(Pathname.pwd)}"
      end
    end
  end
end
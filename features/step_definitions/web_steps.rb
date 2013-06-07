#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file was generated by Cucumber-Rails and is only here to get you a head start
# These step definitions are thin wrappers around the Capybara/Webrat API that lets you
# visit pages, interact with widgets and make assertions about page content.
#
# If you use these step definitions as basis for your features you will quickly end up
# with features that are:
#
# * Hard to maintain
# * Verbose to read
#
# A much better approach is to write your own higher level step definitions, following
# the advice in the following blog posts:
#
# * http://benmabey.com/2008/05/19/imperative-vs-declarative-scenarios-in-user-stories.html
# * http://dannorth.net/2011/01/31/whose-domain-is-it-anyway/
# * http://elabs.se/blog/15-you-re-cuking-it-wrong
#

require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

# Single-line step scoper
When /^(.*) within (.*[^:])$/ do |step_name, parent|
  with_scope(parent) { step step_name }
end

# Multi-line step scoper
When /^(.*) within (.*[^:]):$/ do |step_name, parent, table_or_string|
  with_scope(parent) { step "#{step_name}:", table_or_string }
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )press "([^"]*)"$/ do |button|
  click_button(button)
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  click_link(link)
end

When /^(?:|I )fill in "([^"]*)" with "([^"]*)"$/ do |field, value|
  fill_in(field, :with => value)
end

When /^(?:|I )fill in "([^"]*)" for "([^"]*)"$/ do |value, field|
  fill_in(field, :with => value)
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select or option
# based on naming conventions.
#
When /^(?:|I )fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    step(%{I fill in "#{name}" with "#{value}"})
  end
end

When /^(?:|I )select "([^"]*)" from "([^"]*)"$/ do |value, field|
  begin
    select(value, :from => field)
  rescue Capybara::ElementNotFound
    container = find(:xpath, "//label[contains(., '#{field}')]/parent::*/*[contains(@class, 'select2-container')]")
    container.find(".select2-choice").click
    find(:xpath, "//*[@id='select2-drop']/descendant::li[contains(., '#{value}')]").click
  end
end

When /^(?:|I )check "([^"]*)"$/ do |field|
  check(field)
end

When /^(?:|I )uncheck "([^"]*)"$/ do |field|
  uncheck(field)
end

When /^(?:|I )choose "([^"]*)"$/ do |field|
  choose(field)
end

When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |path, field|
  attach_file(field, File.expand_path(path))
end

Then /^(?:|I )should see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_xpath('//*', :text => regexp)
  else
    assert page.has_xpath?('//*', :text => regexp)
  end
end

Then /^(?:|I )should not see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_no_content(text)
  else
    assert page.has_no_content?(text)
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_no_xpath('//*', :text => regexp)
  else
    assert page.has_no_xpath?('//*', :text => regexp)
  end
end

Then /^the "([^"]*)" field(?: within (.*))? should contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" field(?: within (.*))? should not contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" field should have the error "([^"]*)"$/ do |field, error_message|
  element = find_field(field)
  classes = element.find(:xpath, '..')[:class].split(' ')

  form_for_input = element.find(:xpath, 'ancestor::form[1]')
  using_formtastic = form_for_input[:class].include?('formtastic')
  error_class = using_formtastic ? 'error' : 'field_with_errors'

  if classes.respond_to? :should
    classes.should include(error_class)
  else
    assert classes.include?(error_class)
  end

  if page.respond_to?(:should)
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      error_paragraph.should have_content(error_message)
    else
      page.should have_content("#{field.titlecase} #{error_message}")
    end
  else
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      assert error_paragraph.has_content?(error_message)
    else
      assert page.has_content?("#{field.titlecase} #{error_message}")
    end
  end
end

Then /^the "([^"]*)" field should have no error$/ do |field|
  element = find_field(field)
  classes = element.find(:xpath, '..')[:class].split(' ')
  if classes.respond_to? :should
    classes.should_not include('field_with_errors')
    classes.should_not include('error')
  else
    assert !classes.include?('field_with_errors')
    assert !classes.include?('error')
  end
end

Then /^the "([^"]*)" checkbox(?: within (.*))? should be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_true
    else
      assert field_checked
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within (.*))? should not be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_false
    else
      assert !field_checked
    end
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')}

  if actual_params.respond_to? :should
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end

Then /^show me the page$/ do
  save_and_open_page
end

# newly generated until here

When /^I wait(?: (\d+) seconds)? for(?: the)? [Aa][Jj][Aa][Xx](?: requests?(?: to finish)?)?$/ do |timeout|
  ajax_done = lambda do
    page.evaluate_script(%Q{
      (function (){
        var done = true;

        if (window.jQuery) {
          if (!window.jQuery.isReady || window.jQuery.active != 0) {
            done = false;
          }
        }
        if (window.Prototype && window.Ajax) {
          if (window.Ajax.activeRequestCount != 0) {
            done = false;
          }
        }

        return done;
      }())
    }.gsub("\n", ''))
  end

  timeout = timeout.present? ?
              timeout.to_f :
              5.0

  wait_until(timeout, :i_know_im_immoral => true) do
    ajax_done.call
  end
end

Then /^there should be a( disabled)? "(.+)" field( visible| invisible)?(?: within "([^\"]*)")?(?: if plugin "(.+)" is loaded)?$/ do |disabled, fieldname, visible, selector, plugin_name|
  if plugin_name.nil? || Redmine::Plugin.installed?(plugin_name)
    with_scope(selector) do
      if defined?(Spec::Rails::Matchers)
        find_field(fieldname).should_not be_nil
        if visible && visible == " visible"
          find_field(fieldname).should be_visible
        elsif visible && visible == " invisible"
          find_field(fieldname).should_not be_visible
        end

        if disabled
          find_field(fieldname)[:disabled].should == "disabled"
        else
          find_field(fieldname)[:disabled].should == nil
        end
      else
        assert_not_nil find_field(fieldname)
      end
    end
  end
end

Then /^there should not be a "(.+)" field(?: within "([^\"]*)")?$/ do |fieldname, selector|
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      lambda {find_field(fieldname)}.should raise_error(Capybara::ElementNotFound)
    else
      assert_nil find_field(fieldname)
    end
  end
end

Then /^there should be a "(.+)" button$/ do |button_label|
  if defined?(Spec::Rails::Matchers)
    page.should have_xpath("//input[@value='#{button_label}']")
  else
    raise NotImplementedError, "Only Matcher implemented"
  end
end

Then /^the "([^\"]*)" select(?: within "([^\"]*)")? should have the following options:$/ do |field, selector, option_table|
  options_expected = option_table.raw.collect(&:to_s)

  with_scope(selector) do

    field = find_field(field)
    options_actual = field.all('option').collect(&:text)

    if defined?(Spec::Rails::Matchers)
      options_actual.should =~ options_expected
    else
      raise NotImplementedError, "Only Matcher implemented"
    end
  end
end

# This needs an active js driver to work properly
Given /^I (accept|dismiss) the alert dialog$/ do |method|
  if Capybara.current_driver.to_s.include?("selenium")
    page.driver.browser.switch_to.alert.send(method.to_s)
  end
end

# that's capybara's old behaviour: clicking the first button that matches
When /^(?:|I )click on the first button matching "([^"]*)"$/ do |button|
  first(:button, button).click
end

def find_lowest_containing_element text, selector
  elements = []

  node_criteria = "[contains(normalize-space(.), \"#{text}\") and not(self::script) and not(child::*[contains(normalize-space(.), \"#{text}\")])]"

  if selector
    search_string = Nokogiri::CSS.xpath_for(selector).first + "//*#{node_criteria}"
    search_string += " | " + Nokogiri::CSS.xpath_for(selector).first + "#{node_criteria}"
  else
    search_string = "//*#{node_criteria}"
  end
  elements = all(:xpath, search_string)

rescue Nokogiri::CSS::SyntaxError
  elements
end

def disable_warn_unsaved_popup
  # disable WarnLeavingUnsaved function call when testing with selenium as this
  # will freeze the server

  if defined?(ChiliProject::VERSION::MAJOR) &&
     ChiliProject::VERSION::MAJOR > 1 &&
     Capybara.current_driver.to_s.include?("selenium")

    page.execute_script("window.onbeforeunload = null")
  end
end

require 'timeout'

def wait_until(seconds = 5, options = {}, &block)
  unless options[:i_know_im_immoral]
    raise "You are immoral. I can't stand this. Goodbye.

You really shouldn't use wait_until and wait for an element
using Capybara instead, e.g. using page.should have_selector(...)
See http://www.elabs.se/blog/53-why-wait_until-was-removed-from-capybara
"
    end
  Timeout.timeout(seconds, &block)
end

When /^I confirm popups$/ do
  page.driver.browser.switch_to.alert.accept    
end

Then(/^I should see a confirm dialog$/) do
  page.should have_selector("#confirm_dialog")
end
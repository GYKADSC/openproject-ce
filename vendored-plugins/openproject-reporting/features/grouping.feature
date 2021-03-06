#-- copyright
# OpenProject Reporting Plugin
#
# Copyright (C) 2010 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

Feature: Groups

  Background:
    Given there is a standard cost control project named "First Project"
    And I am already logged in as "controller"
    And I am on the Cost Reports page for the project called "First Project"

  @javascript
  Scenario: We got some awesome default settings
    Then I should see "Week (Spent)" in columns
    And I should see "Work package" in rows

  @javascript
  Scenario: A click on clear removes all groups
    When I click on "Clear"
    Then I should not see "Week (Spent)" in columns
    And I should not see "Work package" in rows
    And I group rows by "User"
    And I group rows by "Cost type"

    When I click on "Clear"

    Then I should not see "Week (Spent)" in columns
    And I should not see "Work package" in rows
    And I should not see "User" in rows
    And I should not see "Cost type" in rows

  @javascript
  Scenario: Groups can be added to either rows or columns
    When I click on "Clear"
    And I group columns by "Work package"

    Then I should see "Work package" in columns
    When I group rows by "Project"
    Then I should see "Project" in rows

  @javascript
  Scenario: Groups can be removed from rows and columns
    When I click on "Clear"
    And I group columns by "Work package"
    And I group rows by "Project"

    Then I should see "Work package" in columns
    And I should see "Project" in rows

    When I remove "Project" from rows
    And I remove "Work package" from columns

    Then I should not see "Work package" in columns
    And I should not see "Project" in rows

  @javascript
  Scenario: Groups get restored after sending a query
    When I click on "Clear"
    And I group columns by "Work package"
    And I group columns by "Project"
    And I group rows by "User"
    And I group rows by "Cost type"
    And I send the query

    Then I should see "Project" in columns
    And I should see "Work package" in columns
    And I should see "User" in rows
    And I should see "Cost type" in rows


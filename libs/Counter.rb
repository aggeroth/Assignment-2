# --------------------------------------------------------------------------------------------------------------
#
# ASSIGNMENT 2 - Multithread vs. Select vs. Epoll
#
# SOURCE FILE: Counter.rb - A class that initializes the amount data being transferred to 0
#
# FUNCTIONS:	total_data
#
# VERSION: 1
#
# DATE: February 23rd, 2014 : 12:30AM
#
# DUE DATE: February 24th, 2014 : 12:30AM
#
# AUTHOR: Martin Javier
#
# OVERVIEW:
# This program will count the amount of data being received from the client. Though, this
# program is primarily used for EventMachine reactor in order to make the program leaner.
#
# USAGE:
# count = Counter.new
#
# --------------------------------------------------------------------------------------------------------------
class Counter

    # This reads and write an attribute being accesses from the class
    attr_accessor :total_data

    def initialize
      @total_data = 0
    end

    #Overides libs/Counter.rb total data to make incremental changes
    def total_data=(num)
      @total_data += num
    end
end
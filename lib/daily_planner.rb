#!/usr/bin/env ruby

# file: daily_planner.rb

require 'date'
require 'dynarex'
require 'fileutils'


class DailyPlanner
  
  attr_reader :to_s

  def initialize(filename='daily-planner.txt', path: '.', 
                                         now: DateTime.now.to_date, config: {})
    
    @filename, @path, @now = filename, path, now
    
    fpath = File.join(path, filename)
    
    if File.exists?(fpath) then
      
      @rx = import_to_rx(File.read(fpath))
      @d = Date.parse(@rx.date)
      archive()
      
      # if the date isn't today then update it to today
      refresh() if @d != @now

    else      
      @rx = new_rx
    end
    
    # check for weekly-planner entries which 
    #   should be added to the daily-planner
    weeklyplanner_filepath = config[:weeklyplanner_filepath]
    
    if weeklyplanner_filepath then
      
      dx = Dynarex.new weeklyplanner_filepath
      record = dx.find_by_id (now+1).strftime("%Y%m%d")      
      @rx.tomorrow << "\n" + record.x.lines[2..-1].join if record

    end
    
  end

  def rx()
    @rx
  end
  
  def save(filename=@filename)
    
    s = File.basename(filename) + "\n" + rx_to_s(@rx).lines[1..-1].join
    File.write File.join(@path, filename), s
        
  end
  
  def to_s()
    rx_to_s @rx
  end

  private
  
  def archive()
    
    # archive the daily planner
    # e.g. dailyplanner/2015/d121215.xml
        
    archive_path = File.join(@path, @d.year.to_s)
    FileUtils.mkdir_p archive_path    
    filename = @d.strftime("d%d%m%Y.xml")
    
    File.write File.join(archive_path, filename), rx.to_xml
    
  end
    
  def import_to_rx(s)
    
    rx = new_rx()
    
    rows = s.split(/.*(?=^[\w, ]+\n\-+)/)

    rx.date =  Date.parse(rows[1].lines.first.chomp)
    rx.today = rows[1].lines[2..-1].join.strip
    rx.tomorrow = rows[2].lines[2..-1].join.strip

    return rx
    
  end

  def rx_to_s(rx)

    def format_row(heading, s)
      
      content = s.clone
      content.prepend "\n\n" unless content.empty?
      "%s\n%s%s" % [heading, '-' * heading.length, content]
      
    end

    def ordinal(n)
      n.to_s + ( (10...20).include?(n) ? 'th' : \
                      %w{ th st nd rd th th th th th th }[n % 10] )
    end

    d = Date.parse(rx.date)

    heading =  "%s, %s %s" % [Date::DAYNAMES[d.wday], ordinal(d.day), 
                                                Date::ABBR_MONTHNAMES[d.month]]
    rows = [format_row(heading, rx.today)]
    rows << format_row('Tomorrow', rx.tomorrow)

    title = File.basename(@filename)
    title + "\n" + "=" * title.length + "\n\n%s\n\n" % [rows.join("\n\n")]

  end
  
  def new_rx(today: '', tomorrow: '')
    
    title = "Daily Planner"
    rx = RecordX.new({title: title, date: @now, \
                                             today: today, tomorrow: tomorrow})    
    return rx
  end

  def refresh()
    
    if @d != @now then
      
      @rx = if @d == @now - 1 and @rx.tomorrow.strip.length  > 0 then
        new_rx(today: @rx.tomorrow)      
      else
        new_rx()
      end
      
    end
  end

end
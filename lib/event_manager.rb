require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end



def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)


contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end

end


# Assignment 

def clean_phone_number(phone)
  phone=phone.to_s.gsub(/\W/,"")
  phone_length=phone.length
  if phone_length==10 
    phone
  elsif (phone_length==11 && phone[0]=='1')
    phone[1..10]
  else
    "bad number"
  end
end


def most_frequent(data)
  count = Hash.new(0)
  data.each {|d| count[d] += 1}
  count.sort_by { |d,number| number}.last[0]
end

reg_hour=[] 
reg_wday=[]
contents.each do |row|
  phone = clean_phone_number(row[:homephone])
  reg_date = row[:regdate]
  reg_date_format = DateTime.strptime(reg_date,"%m/%d/%y %H:%M")
  reg_hour.push(reg_date_format.hour)
  reg_wday.push(reg_date_format.wday)
  puts phone
end

num_to_wday = {0=>"Sunday",1=>"Monday",2=>"Tuesday",3=>"Wednesday",4=>"Thursday",5=>"Friday",6=>"Saturday"}

puts ("Hour of the day most people registered - #{most_frequent(reg_hour)}:00")
puts ("Day of the week most people registered - #{num_to_wday[most_frequent(reg_wday)]}")

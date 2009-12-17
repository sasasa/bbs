#:db           => "%Y-%m-%d %H:%M:%S",
#:number       => "%Y%m%d%H%M%S",
#:time         => "%H:%M",
#:short        => "%d %b %H:%M",
#:long         => "%B %d, %Y %H:%M",
#:long_ordinal => lambda { |time| time.strftime("%B #{time.day.ordinalize}, %Y %H:%M") },
#:rfc822       => "%a, %d %b %Y %H:%M:%S %z" }

#Time::DATE_FORMATS[:simple] = "%Y-%m-%d<br />%H:%M:%S"
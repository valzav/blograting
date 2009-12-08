puts "loading seeds data.."

Platform.create(
  :name => 'lj',
  :make => 'lj',
  :selector_post => '.entry-content; .entry-item; .asset-body',
  :url_regexp => 'livejournal.com'
)

Platform.create(
  :name => 'liveinternet.ru',
  :make => 'liveinternet',
  :selector_post => '.CONBL',
  :url_regexp => 'liveinternet.ru'
)

Platform.create(
  :name => 'diary.ru',
  :make => 'diary.ru',
  :selector_post => '.postInner',
  :url_regexp => 'diary.ru'
)

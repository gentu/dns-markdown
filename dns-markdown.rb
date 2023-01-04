#!/usr/bin/ruby

require 'mechanize'
require 'json'
require 'optparse'
require 'nokogiri'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: dns-markdown.rb [options]'

  opts.on('-u', '--update', 'Run update') do |u|
    options[:update] = u
  end

  opts.on('-s', '--show', 'Show results') do |s|
    options[:show] = s
  end
end.parse!

request = Mechanize.new

url = 'https://www.dns-shop.ru/catalogMarkdown/category/update/'

params = {
  'city': 'tula',
  '1[min]': '',
  '1[max]': '',
  'offset': '0',
}

request.request_headers = {
  'X-Requested-With': 'XMLHttpRequest',
}

response = request.get url, params=params

File.open('dns.txt', 'w') do |f|
  f.write response.at
end

response = File.readlines 'dns.txt'
json = JSON.parse response[0]
p json['isNextLoadAvailable']
html =  Nokogiri::HTML.fragment json['html']
items_now = {}
html.search('div.product').each do |product|
  items_now[product.at('a.ec-price-item-link')['href'].split('/').last] = {
    name: product.at('div.item-name').children[0].text,
    price: product.at('div.price_g').children[0].text.delete(' '),
    grade: product.search('.small-screens span.active').size,
    reasons: product.search('span.reasons-inline').map { |reason| reason.text },
    desc: product.at('div.characteristic-description').text.delete("\n\t"),
}
end
p items_now.first

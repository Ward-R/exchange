#!/usr/bin/env ruby
# --- I did not write this code, AI did ---


require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# --- fetch_url function ---
def fetch_url(uri)
  begin
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    return http.request(request)
  rescue StandardError => e
    puts "Error fetching URL: #{e.message}"
    return nil
  end
end

# --- fetch_currency_data function ---
def fetch_currency_data(date = 'latest', base_currency = 'cad') # Default base is CAD
  url = "https://#{date}.currency-api.pages.dev/v1/currencies/#{base_currency}.json"

  begin
    puts "Fetching URL: #{url}"
    uri = URI(url)
    response = fetch_url(uri)

    if response && response.code == '200'
      puts "URL successful!"
      return response
    end

    puts "URL failed."
    return nil

  rescue URI::InvalidURIError => e
    puts "Invalid URI error: #{e.message}"
    return nil
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
    return nil
  end
end

# --- convert_cad_to_jpy function ---
def convert_cad_to_jpy(amount_cad)
  response = fetch_currency_data('latest', 'cad')

  if response
    begin
      data = JSON.parse(response.body)
      cad_data = data['cad']
      jpy_rate = cad_data['jpy']

      if jpy_rate
        converted_amount_jpy = amount_cad * jpy_rate
        return converted_amount_jpy
      else
        puts "Exchange rate for JPY not found."
        return nil
      end

    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e.message}"
      return nil
    end
  else
    puts "Failed to fetch currency data."
    return nil
  end
end

# --- convert_jpy_to_cad function ---
def convert_jpy_to_cad(amount_jpy)
  response = fetch_currency_data('latest', 'jpy')

  if response
    begin
      data = JSON.parse(response.body)
      jpy_data = data['jpy']
      cad_rate = jpy_data['cad']

      if cad_rate
        converted_amount_cad = amount_jpy * cad_rate
        return converted_amount_cad
      else
        puts "Exchange rate for CAD not found."
        return nil
      end

    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e.message}"
      return nil
    end
  else
    puts "Failed to fetch currency data."
    return nil
  end
end

# --- Example usage (flexible amount, CAD to JPY)---
print "Enter the amount of CAD to convert to JPY: "
amount_cad = gets.chomp.to_f

converted_amount_jpy = convert_cad_to_jpy(amount_cad)

if converted_amount_jpy
  puts "#{amount_cad} CAD is equal to #{converted_amount_jpy.round(2)} JPY"
end


# --- Example usage (flexible amount, JPY to CAD)---
print "Enter the amount of JPY to convert to CAD: "  # Prompt for JPY input
amount_jpy = gets.chomp.to_f

converted_amount_cad = convert_jpy_to_cad(amount_jpy) # Use the JPY to CAD function

if converted_amount_cad
  puts "#{amount_jpy} JPY is equal to #{converted_amount_cad.round(2)} CAD"
end


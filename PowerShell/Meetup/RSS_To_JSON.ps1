# Powershell script to pull Event URLs from meetup search url 
# example: https://www.meetup.com/find/?location=gb--r3--Belfast&source=EVENTS&keywords=DevOps
# loop the locations Belfast, Dublin, London, Birmingham, Manchester, Bangladesh, Madrid, Edinburgh, Newcastle
# Current example has Belfast in the URL, so we will replace that with the other locations in the loop
# For each event generate the RSS feed URL and save it to a variable before printing

$keywords = "DevOps"
# Define the locations to loop through
$locations = @("gb--r3--Belfast", "ie--Dublin", "gb--London", "gb--43--Birmingham", "gb--18--Manchester", "bd--Gurudaspur", "es--Madrid", "gb--u8--Edinburgh", "gb--r3--Newcastle")
$eventLimitPerLocation = 40
# Base URL for the meetup search
$baseUrl = "https://www.meetup.com/find/?location=&source=EVENTS&keywords=$keywords&dateRange=next-week"
# Collection variable for RSS feed URLs
$rssFeedUrls = @()
# Aggregate RSS content into JSON
$events = @()
# Loop through each location
foreach ($location in $locations) {
    # Generate the search URL for the current location
    $searchUrl = [string]::Format($baseUrl, $location)
    Write-Host "Searching for events in $location at $searchUrl"
    
    # Use Invoke-WebRequest to get the HTML content of the search page
    try {
        $response = Invoke-WebRequest -Uri $searchUrl -UseBasicParsing
        # Parse the HTML to find event URLs (this is a simplified example and may need adjustments based on the actual HTML structure)
        $eventUrls = $response.Links | Where-Object { $_.href -like "*meetup.com/*/events/*" } | Select-Object -ExpandProperty href
        $eventUrls = $eventUrls | Select-Object -First $eventLimitPerLocation
        
        # Generate RSS feed URLs for each event and print them
        $eventCount = 0
        foreach ($eventUrl in $eventUrls) {
            # Assuming the RSS feed URL can be derived from the event URL (this is a placeholder logic)
            $rssFeedUrl = $eventUrl -replace "/events/", "/events/rss/"
            Write-Host "Event $eventCount for $location"
            try {
                # Fetch the RSS feed
                $rssResponse = Invoke-WebRequest -Uri $rssFeedUrl -UseBasicParsing
                [xml]$rssContent = $rssResponse.Content
        
                # Extract events from RSS feed
                $item = $rssContent.rss.channel.item | Select-Object -First 1
                $eventDate = [datetime]$item.pubDate
            
                $title = [string]$item.title."#cdata-section"
                $title = $title.Trim()
                Write-Host "Processing event: $title on $($eventDate.ToString("yyyy-MM-dd")) at $location"
                
                $summary = [string]$item.description."#cdata-section"
                $summary = $summary.Trim()
                if ([string]::IsNullOrWhiteSpace($summary)) { $summary = "No summary" }
                
                $event = @{
                    title    = $title
                    date     = $eventDate.ToString("yyyy-MM-dd HH:mm:ss")
                    location = $location
                    summary  = $summary
                    link     = [string]$item.link
                }
                $events += $event
            
        
            }
            catch {
                Write-Host "Error fetching RSS feed $rssFeedUrl`: $_"
            }
            $eventCount++
        }
    }
    catch {
        Write-Host "Error fetching events for $location`: $_"
    }
}



# Convert to JSON and save to file
$outputPath = "/Events/events.json"
$events | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath -Encoding UTF8
Write-Host "Events aggregated and saved to $outputPath"


command: 'curl -s "http://feeds.feedburner.com/brainyquote/QUOTEBR"'

refreshFrequency: 30000

style: """
  bottom: 90px
  left: 0
  color: #fff
  font-family: Gotham Light
  text-align: center
  width: 100%


  .output
    # padding: 5px 10px
    width: 100%
    font-size: 20px
    font-weight: lighter
	  font-smoothing: antialiased

  .author, .example, .example-meaning
    text-transform: capitalize
    font-size: 14px
    margin-top: 5px
  .author
    text-align: center
"""

render: (output) -> """
  <div class="output">
    <div class="quote"></div>
    <div class="author"></div>
  </div>
"""

update: (output, domEl) ->
  # Define constants, and extract the juicy html.
  dom = $(domEl)
  xml = $.parseXML(output)
  $xml = $(xml)
  description = $.parseHTML($xml.find('description').eq(1).text())
  $description = $(description)

 # Find the info we need, and inject it into the DOM.
  dom.find('.quote').html $xml.find('description').eq(2)
  dom.find('.author').html $xml.find('title').eq(2)

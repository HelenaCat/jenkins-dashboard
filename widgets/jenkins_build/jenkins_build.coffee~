class Dashing.JenkinsBuild extends Dashing.Widget

#This file defines how the data, retrieved via data-bind is displayed on the widget.
#If you want to change the background color of the widget, the weather report, the stability text or the information about the last build, change it here.

  @accessor 'value', Dashing.AnimatedValue
  
  #Change the background color of the widget, according to the success of the build. Values are hex values.
  @accessor 'bgColor', ->
    if @get('disabled') == "disabled"
      "#050505"
    else if @get('currentResult') == "SUCCESS"
      "#10942B"
    else if @get('currentResult') == "FAILURE"
      "#E32424"
    else if @get('currentResult') == "PREBUILD"
      "#ff9618"
    else if @get('currentResult') == "UNSTABLE"
      "#E3B912"
    else
      "#999"
      
  #Change the way the weather is displayed. Right now, the name of the icon is parsed and an image is shown accordingly.
  #Note: the local (Alcatel-Lucent) links didn't seem to work on the tv screen, so the other ones were added. Just change the source to the one you wish.
  @accessor 'weather', ->
    source = "https://svn.jenkins-ci.org/tags/hudson-1_162/hudson/main/war/resources/images/32x32/health-"
    #source = "https://na.be.alcatel-lucent.com/jenkins/static/e3d393b8/images/32x32/health-"
    if @get('disabled') == "disabled"
       "http://www.slidepoint.net/_engine/images/clipart/stars/shape_square_black.png"
    else if @get('icon') == "health-00to19.png"
       source + "00to19.gif"
    else if @get('icon') == "health-20to39.png"
       source + "20to39.gif"
    else if @get('icon') == "health-40to59.png" 
       source + "40to59.gif"
    else if @get('icon') == "health-60to79.png"
      source + "60to79.gif"
    else if @get('icon') == "health-80plus.png"
       source + "80plus.gif"
 
  #Change the text about the stability of the builds.
  @accessor 'stability', ->
    if @get('building_info') == true
        "Building..."
    else if @get('disabled') == "disabled"
        "Disabled"
    else if @get('health') == "Build stability: No recent builds failed."
        "No recent builds failed."
    else if @get('health') == "Build stability: All recent builds failed."
        "All recent builds failed."
    else if @get('currentResult') == "SUCCESS"
        @get('health').split(" ")[2] + "/" + @get('health').split(" ")[7] + " builds failed."
    else if @get('currentResult') == "UNSTABLE"
        @get('health').split(" ")[2] + "/" + @get('health').split(" ")[10] + " tests failed."
    else if @get('currentResult') == "FAILURE"
        @get('health').split(" ")[2] + "/" + @get('health').split(" ")[7] + " builds failed."


  @accessor 'color-m', ->
    if @get('building_info') == true
        "#FFFFFF"
    else
        @get('bgColor')
        
  @accessor 'background-color-m', ->
    if @get('building_info') == true
        "#000000"
    else
        @get('bgColor')
 
  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".jenkins-build").val(value).trigger('change')
 
  ready: ->
      meter = $(@node).find(".jenkins-build")
      $(@node).fadeOut().css('background-color', @get('bgColor')).fadeIn()
      meter.attr("data-bgcolor", meter.css("background-color"))
      meter.attr("data-fgcolor", meter.css("color"))
      meter.knob()
       
  #Actions to be performed when new data is received.
  onData: (data) ->
    icon = $(@node).find(".icon")
    description = $(@node).find(".stability")
    if data.building_info isnt true   #When the build is not running, hide the meter.
      $(@node).find(".jenkins-build").knob().hide()
    else
      $(@node).find(".jenkins-build").knob().show()
    if data.currentResult isnt data.lastResult
      $(@node).fadeOut().css('background-color', @get('bgColor')).fadeIn() #If the dashboard is restarted on the server-side, let the widget fade in again.
     icon.html($('<img src=\"' + @get('weather')  + '\" />')) #Replace the icon text of the weather with the image, as replaced above.
     description.html(@get('stability')) #Replace the description with the stability report (instead of the sentence, a ratio is shown, as defined above in the file).


  
  #Change the way the time stamp of the last build is shown. Makes use of the moment.js library.
  Batman.Filters.dateFormat = (date) ->
    moment(date).format("DD-MM-YYYY HH:mm:ss")
 

         



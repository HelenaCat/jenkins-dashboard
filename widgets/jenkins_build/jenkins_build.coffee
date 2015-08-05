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
  @accessor 'weather', ->
    if @get('disabled') == "disabled"
       "http://www.slidepoint.net/_engine/images/clipart/stars/shape_square_black.png"
    else if @get('icon') == "health-00to19.png"
       "https://na.be.alcatel-lucent.com/jenkins/static/e3d393b8/images/32x32/health-00to19.png"
    else if @get('icon') == "health-20to39.png"
       "https://na.be.alcatel-lucent.com/jenkins/static/e3d393b8/images/32x32/health-20to39.png"
    else if @get('icon') == "health-40to59.png" 
       "https://na.be.alcatel-lucent.com/jenkins/static/e3d393b8/images/32x32/health-40to59.png"
    else if @get('icon') == "health-60to79.png"
       "https://na.be.alcatel-lucent.com/jenkins/static/e3d393b8/images/32x32/health-60to79.png"
    else if @get('icon') == "health-80plus.png"
       "https://na.be.alcatel-lucent.com/jenkins/static/e3d393b8/images/32x32/health-80plus.png"
 
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
      meter.attr("data-bgcolor", @get('background-color-m'))
      meter.attr("data-fgcolor", @get('color-m'))
      meter.knob()
       
  #Actions to be performed when new data is received.
  onData: (data) ->
    icon = $(@node).find(".icon")
    description = $(@node).find(".stability")
    if data.currentResult isnt data.lastResult
      $(@node).fadeOut().css('background-color', @get('bgColor')).fadeIn() #If the dashboard is restarted on the server-side, let the widget fade in again.
     icon.html($('<img src=\"' + @get('weather')  + '\" />')) #Replace the icon text of the weather with the image, as replaced above.
     description.html(@get('stability')) #Replace the description with the stability report (instead of the sentence, a ratio is shown, as defined above in the file).
     if data.building_info isnt true
       $(@node).find(".jenkins-build").knob().hide()
     else
       $(@node).find(".jenkins-build").knob().show()

  
  #Change the way the time stamp of the last build is shown. Makes use of the moment.js library.
  Batman.Filters.dateFormat = (date) ->
    moment(date).format("DD-MM-YYYY HH:mm:ss")
 

         


